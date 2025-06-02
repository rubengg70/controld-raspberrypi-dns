#!/bin/bash

# === Reporte Ejecutivo de Correos (msmtp) ===
EMAIL="rggalindo54@gmail.com"
LOG_DIR="/root/logs"
TMP_LOG="/tmp/msmtp_report.log"
TMP_MAIL="/tmp/msmtp_report_mail.txt"
DATE_YESTERDAY=$(date -d "yesterday" '+%b %_d')      # Ej: Jun  1
DATE_YESTERDAY_ALT=$(date -d "yesterday" '+%b %d')    # Ej: Jun 01
DATE_LABEL=$(date -d "yesterday" '+%Y-%m-%d')         # Ej: 2025-06-01
TIME_NOW=$(date '+%Y-%m-%d %H:%M:%S')

# === Extraer registros del día anterior ===
> "$TMP_LOG"

# Buscar en log activo (.log)
[[ -f "$LOG_DIR/msmtp.log" ]] && grep -E "$DATE_YESTERDAY|$DATE_YESTERDAY_ALT" "$LOG_DIR/msmtp.log" >> "$TMP_LOG"

# Buscar en log rotado (.log.1)
[[ -f "$LOG_DIR/msmtp.log.1" ]] && grep -E "$DATE_YESTERDAY|$DATE_YESTERDAY_ALT" "$LOG_DIR/msmtp.log.1" >> "$TMP_LOG"

# Buscar en logs comprimidos (.gz)
for f in "$LOG_DIR"/msmtp.log.*.gz; do
    [[ -e "$f" ]] || continue
    zgrep -E "$DATE_YESTERDAY|$DATE_YESTERDAY_ALT" "$f" >> "$TMP_LOG"
done

# === Contadores de éxito y fallo ===
SUCCESS_COUNT=$(grep -c "exitcode=EX_OK" "$TMP_LOG")
FAIL_COUNT=$(grep -v "exitcode=EX_OK" "$TMP_LOG" | grep -c "exitcode=")

# === Componer el cuerpo del correo ===
{
echo "Subject: 📧 Reporte Ejecutivo de Correos – $DATE_LABEL"
echo "To: $EMAIL"
echo "From: $EMAIL"
echo "Content-Type: text/plain; charset=UTF-8"
echo ""
echo "📅 Fecha: $DATE_LABEL"
echo "⏱️ Reporte generado: $TIME_NOW"
echo ""

if [[ -s "$TMP_LOG" ]]; then
    echo "✅ Correos enviados exitosamente: $SUCCESS_COUNT"
    echo "❌ Fallos detectados: $FAIL_COUNT"
    echo ""
    echo "🧾 Detalles del log:"
    echo ""
    cat "$TMP_LOG"
else
    echo "⚠️ No se encontraron registros en msmtp.log para la fecha $DATE_LABEL."
    echo ""
    echo "Esto podría indicar que:"
    echo "– No se envió ningún correo ese día"
    echo "– El log fue rotado y comprimido antes del análisis"
fi
} > "$TMP_MAIL"

# === Enviar el correo o mostrarlo en modo test ===
if [[ "$1" == "--test" ]]; then
    echo "--- MODO TEST ---"
    cat "$TMP_MAIL"
else
    msmtp "$EMAIL" < "$TMP_MAIL"
fi

# === Limpiar archivos temporales ===
rm -f "$TMP_LOG" "$TMP_MAIL"
