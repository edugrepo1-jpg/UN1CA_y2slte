package com.gmhub.uv;

import android.app.AlertDialog;
import android.content.Context;
import android.os.Handler;
import android.os.Looper;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;
import android.widget.TextView;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/** Native One UI Settings content. No service, polling, preset or auto-apply. */
public final class UndervoltPanel extends LinearLayout {
    private final Handler main = new Handler(Looper.getMainLooper());
    private final TextView status;
    private final LinearLayout rows;
    private final Button refresh;
    private final List<Button> controls = new ArrayList<>();
    private ExecutorService worker;
    private AlertDialog dialog;
    private boolean busy;
    private int generation;
    private String lastResult;

    public UndervoltPanel(Context c, AttributeSet attrs) {
        super(c, attrs);
        setOrientation(VERTICAL);
        int p = dp(16); setPadding(p, p, p, p);
        addView(text("Undervolt", 22));
        addView(text("Redução percentual da tensão solicitada ao firmware. Não altera frequência nem governador. "
            + "Os valores são individuais e voltam ao padrão após reiniciar.", 15));
        status = text("Aguardando leitura do GMKernel…", 15); addView(status);
        refresh = new Button(c); refresh.setText("Atualizar valores");
        refresh.setOnClickListener(v -> load()); addView(refresh);
        rows = new LinearLayout(c); rows.setOrientation(VERTICAL); addView(rows);
    }

    private int dp(int value) { return Math.round(value * getResources().getDisplayMetrics().density); }
    private TextView text(String value, int size) {
        TextView v = new TextView(getContext()); v.setText(value); v.setTextSize(size);
        v.setPadding(0, dp(8), 0, dp(8)); return v;
    }

    @Override protected void onAttachedToWindow() {
        super.onAttachedToWindow(); generation++;
        worker = Executors.newSingleThreadExecutor(); load();
    }

    @Override protected void onDetachedFromWindow() {
        generation++;
        if (dialog != null) { dialog.dismiss(); dialog = null; }
        if (worker != null) { worker.shutdownNow(); worker = null; }
        main.removeCallbacksAndMessages(null);
        busy = false; super.onDetachedFromWindow();
    }

    private void enabled(boolean value) {
        busy = !value; refresh.setEnabled(value);
        for (Button control : controls) control.setEnabled(value);
    }

    private void load() {
        if (busy || worker == null) return;
        enabled(false); int g = generation;
        worker.execute(() -> {
            try {
                Map<String, Integer> values = UvBackend.read();
                main.post(() -> { if (g == generation && isAttachedToWindow()) { display(values); enabled(true); } });
            } catch (Exception ex) {
                main.post(() -> {
                    if (g != generation || !isAttachedToWindow()) return;
                    rows.removeAllViews(); controls.clear(); enabled(true);
                    status.setText("É necessário o GMKernel com confirmação de ajustes e acesso root autorizado para Configurações. "
                        + "Nenhum valor foi alterado.\n" + ex.getMessage());
                });
            }
        });
    }

    private void display(Map<String, Integer> values) {
        rows.removeAllViews(); controls.clear();
        status.setText(lastResult != null ? lastResult : "Valores lidos do kernel. Toque em um domínio para escolher seu ajuste.");
        for (int i = 0; i < UvBackend.DOMAINS.length; i++) {
            String domain = UvBackend.DOMAINS[i]; Integer value = values.get(domain);
            if (value == null) continue;
            String label = UvBackend.LABELS[i];
            Button row = new Button(getContext());
            row.setAllCaps(false); row.setMinHeight(dp(56));
            row.setText(label + " · " + value + "%");
            row.setContentDescription(label + ", tensão " + value + " por cento. Alterar");
            row.setOnClickListener(v -> choose(domain, label, value));
            rows.addView(row, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT)); controls.add(row);
        }
    }

    private void choose(String domain, String label, int value) {
        if (busy) return;
        int count = UvBackend.MAX - UvBackend.MIN + 1;
        String[] items = new String[count];
        for (int i = 0; i < count; i++) items[i] = i == 0 ? "0% · padrão" : "−" + i + "%";
        int selected = value <= 0 && value >= UvBackend.MIN ? -value : -1;
        dialog = new AlertDialog.Builder(getContext()).setTitle(label)
            .setSingleChoiceItems(items, selected, (d, which) -> {
                d.dismiss(); int percent = -which;
                if (percent == value) return;
                dialog = new AlertDialog.Builder(getContext()).setTitle("Aplicar " + percent + "%?")
                    .setMessage("Uma redução excessiva pode causar instabilidade. Este ajuste vale para a inicialização atual.")
                    .setNegativeButton("Cancelar", null)
                    .setPositiveButton("Aplicar", (confirmation, button) -> apply(domain, percent)).show();
            }).setNegativeButton("Cancelar", null).show();
    }

    private void apply(String domain, int percent) {
        if (busy || worker == null) return;
        enabled(false); int g = generation;
        status.setText("Aguardando confirmação do kernel…");
        worker.execute(() -> {
            String message;
            try { UvBackend.apply(domain, percent); message = "Solicitação aceita pelo firmware: " + percent + "%."; }
            catch (Exception ex) { message = "Não foi possível confirmar o ajuste. " + ex.getMessage(); }
            final String result = message;
            main.post(() -> {
                if (g != generation || !isAttachedToWindow()) return;
                enabled(true); lastResult = result; status.setText(result);
                // Refresh only after an explicit operation, never on a timer.
                load();
            });
        });
    }
}
