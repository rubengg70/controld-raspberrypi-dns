# controld-raspberrypi-dns

🔧 **Solución resiliente para problemas de ControlD en Raspberry Pi**

Este repositorio contiene una serie de scripts y configuraciones diseñadas para resolver fallas de resolución DNS al usar ControlD en una Raspberry Pi como servidor DNS local, especialmente ante caídas nocturnas o interrupciones en la conectividad TLS hacia los servidores de ControlD.

---

## 📌 Problema identificado

Usuarios que configuran ControlD (`ctrld`) en Raspberry Pi como DNS resolver local pueden experimentar:

- Fallos de resolución DNS al reiniciar `ctrld`
- Caídas recurrentes durante la madrugada
- Reinicios que sobrescriben la configuración (`ctrld.toml`)
- Pérdida de conectividad en entornos con MikroTik, Tailscale o rclone

---

## ✅ Solución implementada

Se desarrolló una solución compuesta por:

1. **Monitoreo periódico del DNS de ControlD**
2. **Selección automática de IPs funcionales (76.76.2.187 o 76.76.10.187)**
3. **Reinicialización controlada del servicio `ctrld`**
4. **Backups automáticos del MikroTik**
5. **Reportes diarios de msmtp por correo electrónico**

---

## 📁 Contenido del repositorio

### `scripts/`

| Archivo                        | Descripción                                                                 |
|-------------------------------|-----------------------------------------------------------------------------|
| `ctrld_bootstrap_selector.sh` | Cambia automáticamente la IP del servidor ControlD si la actual no responde |
| `fetch_mikrotik_backup.sh`    | Descarga el backup del MikroTik y lo sube a Google Drive usando `rclone`    |
| `msmtp_daily_report.sh`       | Envía un resumen diario de los correos enviados por `msmtp`                 |

---

## ⚙️ Requisitos

- Raspberry Pi (recomendado: DietPi)
- `ctrld` instalado y configurado
- `msmtp` para notificaciones por correo
- `rclone` para subir backups a Google Drive
- Acceso vía SCP al MikroTik
- Crontab habilitado para tareas programadas

---

## 🚀 Instrucciones básicas

1. Clona o descarga este repositorio
2. Copia los scripts a tu directorio `/root` o `/opt/scripts`
3. Asigna permisos de ejecución:

```bash
chmod +x ctrld_bootstrap_selector.sh
chmod +x fetch_mikrotik_backup.sh
chmod +x msmtp_daily_report.sh

*/5 * * * * /root/ctrld_bootstrap_selector.sh >> /root/logs/ctrld_monitor.log 2>&1
0 2 * * * /root/fetch_mikrotik_backup.sh
30 2 * * * /root/msmtp_daily_report.sh
```


## 📚 Documentación extendida

👉 Revisa la [bitácora técnica](docs/bitacora_tecnica.md) para conocer en detalle el proceso de análisis, solución implementada y aprendizajes obtenidos.


## 🧠 Créditos y contribución

Este proyecto nace de una experiencia real de troubleshooting y ajustes de red entre una Raspberry Pi, MikroTik y ControlD.  
Compartido con el objetivo de ayudar a otros usuarios que enfrenten problemas similares.



¿Tienes ideas o mejoras? ¡Pull requests y sugerencias son bienvenidos!






