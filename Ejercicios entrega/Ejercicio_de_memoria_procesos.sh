#!/bin/bash

# Función para mostrar procesos activos
mostrar_procesos_activos() {
    echo
    echo "Procesos activos:"
    echo "=================================="
    # ps aux muestra todos los procesos en ejecución
    ps aux
}

# Función para mostrar los procesos que más memoria consumen
mostrar_procesos_mas_memoria() {
    echo
    echo "Procesos que más memoria consumen:"
    echo "=================================="
    read -p "Cuántos procesos desea listar? " cantidad

    # Verifica si la entrada es un número y mayor que 0
    if ! [[ -z "$cantidad" || "$cantidad" =~ ^[0-9]+$ ]] || [ "$cantidad" -le 0 ]; then
        echo "Por favor, ingresa un número válido mayor que 0."
        return
    fi

    # Verificar si ps es GNU o BSD
    # GNU ps tiene la opción --sort, mientras que BSD ps no la tiene
    # Usamos ps --version para determinar la versión
    if ps --version > /dev/null 2>&1; then
        # GNU ps
        # Mostrar los procesos que más memoria consumen
        # ps aux muestra todos los procesos, --sort=-%cpu ordena por uso de CPU de mayor a menor
        # head -n *cantidad* limita la salida a los primeros procesos
        ps aux --sort=-%mem | head -n $(($cantidad + 1))
    else
        # BSD ps (ej. MacOS)
        # Mostrar los procesos que más memoria consumen
        # ps aux muestra todos los procesos, sort ordena por uso de CPU de mayor a menor
        # -nrk 4 ordena numéricamente (-n) y en orden inverso (-r) por la cuarta columna (uso de memoria)
        # head -n *cantidad* limita la salida a los primeros procesos
        ps aux | sort -nrk 4 | head -n $(($cantidad + 1))
    fi
}

# Función para matar los procesos que más memoria consumen
matar_procesos_mas_memoria() {
    echo
    echo "Matar los procesos que más memoria consumen:"
    echo "=================================="
    read -p "Cuántos procesos desea listar? " cantidad

    # Verifica si la entrada es un número y mayor que 0
    if ! [[ -z "$cantidad" || "$cantidad" =~ ^[0-9]+$ ]] || [ "$cantidad" -le 0 ]; then
        echo "Por favor, ingresa un número válido mayor que 0."
        return
    fi

    # Verificar si ps es GNU o BSD
    # GNU ps tiene la opción --sort, mientras que BSD ps no la tiene
    # Usamos ps --version para determinar la versión
    if ps --version > /dev/null 2>&1; then
        # GNU ps
        # Obtener los PIDs de los procesos que más memoria consumen
        # ps aux muestra todos los procesos, --sort=-%mem ordena por uso de memoria de mayor a menor
        # head -n *cantidad* para incluir la cabecera y luego extraer solo los PIDs
        pids=$(ps aux --sort=-%mem | head -n $(($cantidad + 1)) | awk 'NR>1 {print $2}')
    else
        # BSD ps (ej. MacOS)
        # Obtener los PIDs de los procesos que más memoria consumen
        # ps aux muestra todos los procesos, --sort=-%mem ordena por uso de memoria de mayor a menor
        # sort ordena por uso de memoria de mayor a menor
        # -nrk 4 ordena numéricamente (-n) y en orden inverso (-r) por la cuarta columna (uso de memoria)
        # head -n *cantidad* para incluir la cabecera y luego extraer solo los PIDs
        pids=$(ps aux | sort -nrk 4 | head -n $(($cantidad + 1)) | awk 'NR>1 {print $2}')
    fi

    if [ -z "$pids" ]; then
        echo "No hay procesos para matar."
        return
    fi

    echo "Los siguientes procesos serán finalizados:"
    echo "$pids"

    # kill mata los procesos por sus PIDs
    kill $pids
}

# Función para mostrar el uso de memoria
mostrar_uso_memoria() {
    echo
    echo "Uso de memoria:"
    echo "=================================="
    # Verifica si el comando free está disponible
    if ! command -v free &> /dev/null; then
        echo "El comando 'free' no está disponible en este sistema."
        return
    fi

    # free -h muestra el uso de memoria en un formato legible
    free -h
}

# Función para mostrar la carga del sistema
mostrar_carga_sistema() {
    echo
    echo "Carga del sistema:"
    echo "=================================="

    # Verifica si el comando uptime está disponible
    if ! command -v uptime &> /dev/null; then
        echo "El comando 'uptime' no está disponible en este sistema."
        return
    fi

    # uptime muestra la carga del sistema y el tiempo de actividad
    uptime
}

# Función para mostrar el menú de opciones
mostrar_menu() {
    echo
    echo "=================================="
    echo "MENÚ"
    echo "=================================="
    echo "1) Ver procesos activos"
    echo "2) Ver los procesos que más memoria consumen"
    echo "3) Matar los procesos que más memoria consumen"
    echo "4) Ver uso de memoria"
    echo "5) Ver carga del sistema"
    echo "0) Salir"
    echo "=================================="
}

# Bucle para mostrar menú de opciones
while true; do
    mostrar_menu
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) mostrar_procesos_activos ;;
        2) mostrar_procesos_mas_memoria ;;
        3) matar_procesos_mas_memoria ;;
        4) mostrar_uso_memoria ;;
        5) mostrar_carga_sistema ;;
        0) echo "Saliendo del ejercicio..."; break ;;
        *) echo "Opción inválida. Inténtelo otra vez." ;;
    esac
done