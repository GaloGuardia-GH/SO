#!/bin/bash

# Función para mostrar el directorio actual
mostrar_directorio_actual() {
    echo
    echo "Directorio actual:"
    echo "=================================="
    # pwd muestra el directorio de trabajo actual
    pwd
}

# Función para mostrar el directorio actual
listar_archivos() {
    echo
    echo "Lista de archivos en el directorio actual:"
    echo "=================================="
    # ls -l lista los archivos y directorios en el directorio actual
    ls -l
}

# Función para mostrar el usuario actual
mostrar_usuario_actual() {
    echo
    echo "Usuario actual:"
    echo "=================================="
    # whoami muestra el nombre del usuario actual
    whoami
}

# Función para mostrar la fecha y hora actual
mostrar_fecha_hora() {
    echo
    echo "Fecha y hora actual:"
    echo "=================================="
    # date muestra la fecha y hora actual
    date
}

# Función para mostrar procesos activos
mostrar_procesos_activos() {
    echo
    echo "Procesos activos:"
    echo "=================================="
    # ps aux muestra todos los procesos en ejecución
    ps aux
}

# Función para mostrar información del sistema
mostrar_informacion_sistema() {
    echo
    echo "Información del sistema:"
    echo "=================================="
    # uname -o muestra el sistema operativo
    echo "Sistema operativo: $(uname -o)"
    # uname -s muestra el nombre del sistema operativo
    echo "Nombre del sistema operativo: $(uname -s)"
    # uname -n muestra el nombre del nodo de red
    echo "Nombre del nodo de red: $(uname -n)"
    # uname -m muestra la arquitectura del hardware
    echo "Arquitectura del hardware: $(uname -m)"
    # uname -p muestra el tipo de procesador
    echo "Tipo de procesador: $(uname -p)"
    # uname -i muestra la plataforma de hardware
    echo "Plataforma de hardware: $(uname -i)"
    # uname -v muestra la versión del sistema operativo
    echo "Versión del sistema operativo: $(uname -v)"
    # uname -a muestra toda la información del sistema
    echo "Información completa del sistema: $(uname -a)"
    # uname -r muestra la versión del kernel
    echo "Versión del kernel: $(uname -r)"
    # $SHELL muestra la shell actual
    # $SHELL --version muestra la versión de la shell
    echo "Versión de la shell: $SHELL -- $($SHELL --version | head -n 1)"
    # command -v gcc verifica si GCC está instalado y muestra su versión
    if command -v gcc >/dev/null 2>&1; then
        # gcc --version muestra la versión de GCC
        # head -n 1 limita la salida a la primera línea
        echo "Versión de GCC: $(gcc --version | head -n 1)"
    else
        echo "GCC no está instalado."
    fi
}

# Función para mostrar el menú de opciones
mostrar_menu() {
    echo
    echo "=================================="
    echo "MENÚ"
    echo "=================================="
    echo "1) Mostrar el directorio actual"
    echo "2) Listar archivos"
    echo "3) Mostrar el usuario actual"
    echo "4) Mostrar la fecha y hora"
    echo "5) Ver procesos activos"
    echo "6) Ver información del sistema"
    echo "0) Salir"
    echo "=================================="
}

# Bucle para mostrar menú de opciones
while true; do
    mostrar_menu
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) mostrar_directorio_actual ;;
        2) listar_archivos ;;
        3) mostrar_usuario_actual ;;
        4) mostrar_fecha_hora ;;
        5) mostrar_procesos_activos ;;
        6) mostrar_informacion_sistema ;;
        0) echo "Saliendo del ejercicio..."; break ;;
        *) echo "Opción inválida. Inténtelo otra vez." ;;
    esac
done