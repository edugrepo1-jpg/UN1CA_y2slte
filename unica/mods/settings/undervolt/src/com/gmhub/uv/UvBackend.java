package com.gmhub.uv;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/** Fixed sysfs allowlist; no arbitrary path, shell argument or boot-time write. */
public final class UvBackend {
    private static final String ROOT = "/sys/power/percent_margin/";
    public static final String[] DOMAINS = {"lit", "mid", "big", "g3d", "mif"};
    public static final String[] LABELS = {"CPU eficiente · A55", "CPU intermediária · A76",
        "CPU de desempenho · M5", "GPU", "Memória RAM"};
    // User chooses each value in the Hub. Nothing is written when the page opens.
    public static final int MIN = -10;
    public static final int MAX = 0;

    private static String node(String domain) {
        for (String allowed : DOMAINS) if (allowed.equals(domain)) return ROOT + domain + "_margin_percent";
        throw new IllegalArgumentException("Domínio indisponível");
    }

    public static int parsePercent(String value) {
        if (value == null || !value.matches("-?(0|[1-9][0-9]{0,2})"))
            throw new IllegalArgumentException("Valor inválido");
        int n = Integer.parseInt(value);
        if (n < -100 || n > 100) throw new IllegalArgumentException("Valor fora da interface do kernel");
        return n;
    }

    private static String root(String script) throws Exception {
        Process process = new ProcessBuilder("su", "-c", script).redirectErrorStream(true).start();
        try {
            // Runs exclusively on the worker; waiting never blocks Settings' main thread.
            if (!process.waitFor(15, TimeUnit.SECONDS)) throw new IllegalStateException("O acesso root não respondeu");
            ByteArrayOutputStream bytes = new ByteArrayOutputStream();
            try (InputStream in = process.getInputStream()) {
                byte[] chunk = new byte[1024]; int n;
                while ((n = in.read(chunk)) != -1) {
                    if (bytes.size() + n > 8192) throw new IllegalStateException("Resposta inesperada do kernel");
                    bytes.write(chunk, 0, n);
                }
            }
            if (process.exitValue() != 0) throw new IllegalStateException("O kernel recusou o acesso ou o ajuste");
            return new String(bytes.toByteArray(), StandardCharsets.UTF_8).trim();
        } finally { process.destroy(); }
    }

    private static String guard() {
        return "[ \"$(id -u)\" = 0 ] && [ \"$(cat " + ROOT + "gmhub_checked 2>/dev/null)\" = 1 ] || exit 70; ";
    }

    public static Map<String, Integer> read() throws Exception {
        StringBuilder script = new StringBuilder(guard());
        for (String d : DOMAINS) script.append("if [ -r ").append(node(d)).append(" ]; then printf '")
            .append(d).append("='; cat ").append(node(d)).append("; fi; ");
        Map<String, Integer> result = new LinkedHashMap<>();
        for (String line : root(script.toString()).split("\\R")) {
            String[] pair = line.split("=", -1);
            if (pair.length != 2) throw new IllegalStateException("Resposta inválida do kernel");
            node(pair[0]);
            result.put(pair[0], parsePercent(pair[1].trim()));
        }
        if (result.isEmpty()) throw new IllegalStateException("Nenhum domínio compatível");
        return result;
    }

    public static void apply(String domain, int percent) throws Exception {
        String path = node(domain);
        if (percent < MIN || percent > MAX) throw new IllegalArgumentException("Ajuste fora da faixa do Hub");
        // Kernel contract 1 propagates ACPM errors and publishes the new cached
        // margin only after acceptance. Older kernels deliberately fail closed.
        String output = root(guard() + "printf '%s\\n' '" + percent + "' > " + path
            + " || exit 71; cat " + path + " || exit 72");
        if (parsePercent(output) != percent) throw new IllegalStateException("A leitura não confirmou o ajuste");
    }
}
