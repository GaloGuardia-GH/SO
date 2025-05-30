#!/bin/bash

#creamos un nombre para el archivo log
FECHA_LOG="$(date +%Y%m%d%H%M%S)" #usamos el comando date definiendo el formato añomesdiahoraminutossegundos
NOMBRE_LOG="${FECHA_LOG}.txt" #agregamos la extension .txt al nombre

echo ""
echo "==========================================================================="
echo "==========================================================================="
echo ""

#guardamos el archivo log con echo
echo "Se crea el archivo log ${NOMBRE_LOG}."
echo "texto testigo" >> "${NOMBRE_LOG}"
echo ""
echo "==========================================================================="
echo ""

#hacemos caducar la clave de student a los 60 dias
echo "Se establece la caducidad de la contraseña para el usuario student."
passwd -x 60 student
echo ""
echo "==========================================================================="
echo ""

#en lugar de actualizar la fecha y hora de forma manual activaremos la sincronizacion automatica con timedatectl
echo "Se activa la sincronizacion de fecha y hora."
timedatectl set-ntp true #activamos sincronizacion
timedatectl status #comprobamos estado

echo ""
echo "==========================================================================="
echo "==========================================================================="
echo ""

echo "Determinar version de Red Hat."
cat /etc/redhat-release
echo "Determinar version de Kernel."
uname -r

echo ""
echo "==========================================================================="
echo "==========================================================================="
echo ""

echo "Determinar version de Shell."
echo "$SHELL"
echo "Determinar version de Bash."
bash --version
echo "Se muestran Shells alternativos."
cat /etc/shells

echo ""
echo "==========================================================================="
echo "==========================================================================="
echo ""

echo "Determinar version de libreria estandar de C."
ldd --version

echo ""
echo "==========================================================================="
echo "==========================================================================="
echo ""

echo "Revisar historial de comandos."
history

echo ""
echo "==========================================================================="
echo "==========================================================================="
echo ""

echo "Desconectar"
exit