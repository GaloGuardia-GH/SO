#!/bin/bash

# Función para mostrar los procesos activos
mostrar_procesos() {
    echo "Procesos activos (PID, usuario, %CPU, %MEM, comando):"
    echo "========================================"
    # Verificar si ps es GNU o BSD
    # GNU ps tiene la opción --sort, mientras que BSD ps no la tiene
    # Usamos ps --version para determinar la versión
    if ps --version > /dev/null 2>&1; then
        # GNU ps
        # Mostrar los 15 procesos que más CPU consumen
        # ps aux muestra todos los procesos, --sort=-%cpu ordena por uso de CPU de mayor a menor
        # head -n 15 limita la salida a los primeros 15 procesos
        ps aux -- sort=-%cpu | head -n 15
    else
        # BSD ps (ej. MacOS)
        # Mostrar los 15 procesos que más CPU consumen
        # ps aux muestra todos los procesos, sort ordena por uso de CPU de mayor a menor
        # -nrk 3 ordena numéricamente (-n) y en orden inverso (-r) por la tercera columna (uso de CPU)
        # head -n 15 limita la salida a los primeros 15 procesos
        ps aux | sort -nrk 3 | head -n 15
    fi
}

# Función para buscar procesos por nombre
buscar_proceso() {
    read -p "Ingrese el nombre del proceso a buscar: " nombre

    # Verificar si se proporcionó un nombre
    if [[ -z "$nombre" ]]; then
        echo "Debe proporcionar un nombre para buscar."
        return
    fi

    echo "Buscando procesos que coincidan con '$nombre'..."
    echo "========================================"
    # Mostrar los procesos que coinciden con el nombre
    # ps aux muestra todos los procesos, grep busca el nombre proporcionado
    # grep -v grep excluye el propio comando grep de los resultados
    # -i hace la búsqueda insensible a mayúsculas y minúsculas
    ps aux | grep -i "$nombre" | grep -v grep
}

# Función para administrar proceso por PID
administrar_proceso() {
    read -p "Ingrese el PID del proceso que desea administrar: " pid

    # Verificar si se proporcionó un PID
    if [[ -z "$pid" ]]; then
        echo "Debe proporcionar un PID para administrar."
        return
    fi

    # Verificar si el PID es un número válido
    if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
        echo "El PID debe ser un número válido."
        return
    fi

    if ! ps -p "$pid" > /dev/null 2>&1; then
        echo "No existe un proceso con PID $pid."
        return
    fi

    echo "Detalles del proceso PID $pid:"
    echo "========================================"
    # Mostrar detalles del proceso específico
    # ps -p muestra información sobre el proceso con el PID dado
    # -o especifica el formato de salida, en este caso PID, usuario, %CPU, %MEM, estado y comando
    ps -p "$pid" -o pid,user,%cpu,%mem,stat,cmd

    read -p "Desea terminar este proceso? (S/N): " opcion
    if [[ "$opcion" == "S" ]]; then
        echo "Terminando proceso PID $pid..."
        # Termina el proceso con kill
        # kill envía una señal al proceso para terminarlo
        # Si el proceso no existe o no se puede terminar, kill devuelve un código de salida distinto de 0
        kill "$pid" && echo "Proceso $pid terminado." || echo "Error al intentar terminar el proceso."
    else
        echo "Proceso no terminado."
    fi
}

# Función para mostrar los jobs (procesos en la sesión actual)
mostrar_procesos_segundo_plano() {
    echo "Procesos en segundo plano en esta sesión:"
    echo "========================================"
    # jobs muestra los procesos en segundo plano de la sesión actual
    # -l muestra el PID de cada job
    jobs -l
}

# Función para terminar un proceso por nombre (pkill)
kill_proceso() {
    if ! command -v pkill > /dev/null; then
        echo "El comando pkill no está disponible en este sistema."
        echo "Use la opción killall o instale pkill (paquete procps)."
        return
    fi

    read -p "Ingrese el nombre del proceso a terminar (pkill): " nombre

    # Verificar si se proporcionó un nombre
    if [[ -z "$nombre" ]]; then
        echo "Debe proporcionar un nombre para terminar el proceso."
        return
    fi

    # Termina el proceso por nombre
    echo "Terminando procesos con nombre '$nombre'..."
    # pkill envía una señal a todos los procesos que coinciden con el nombre dado
    # Si pkill no encuentra procesos, no hace nada y devuelve un código de salida 1
    # Si pkill encuentra procesos, los termina y devuelve un código de salida 0
    pkill "$nombre" && echo "Procesos '$nombre' terminados." || echo "No se encontraron procesos."
}

# Función para terminar todos los procesos por nombre (killall)
killall_proceso() {
    if ! command -v killall > /dev/null; then
        echo "El comando killall no está disponible en este sistema."
        echo "Instale pkill (paquete procps)."
        return
    fi

    read -p "Ingrese el nombre del proceso a terminar (killall): " nombre

    # Verificar si se proporcionó un nombre
    if [[ -z "$nombre" ]]; then
        echo "Debe proporcionar un nombre para terminar el proceso."
        return
    fi

    # Termina todos los procesos por nombre
    echo "Terminando todos los procesos con nombre '$nombre'..."
    # killall envía una señal a todos los procesos que coinciden con el nombre dado
    # Si killall no encuentra procesos, no hace nada y devuelve un código de salida 1
    # Si killall encuentra procesos, los termina y devuelve un código de salida 0
    killall "$nombre" && echo "Todos los procesos '$nombre' terminados." || echo "No se encontraron procesos."
}

# Función para enviar señales
enviar_senales() {
    echo "1) Terminar procesos por nombre"
    echo "2) Terminar todos los procesos por nombre"
    read -p "Seleccione una opción [1-2]: " opcion

    case $opcion in
        1) kill_proceso;;
        2) killall_proceso;;
        *) echo "Opción inválida.";;
    esac
}

# Función para mostrar el promedio de carga
mostrar_carga() {
    if ! command -v uptime > /dev/null; then
        echo "El comando uptime no está disponible en este sistema."
        return
    fi

    if ! command -v w > /dev/null; then
        echo "El comando uptime no está disponible en este sistema."
        return
    fi

    echo "Promedio de carga del sistema:"
    echo "========================================"
    # uptime muestra el tiempo de actividad del sistema y la carga promedio
    # La salida de uptime incluye el tiempo de actividad y la carga promedio en los últimos 1, 5 y 15 minutos
    uptime
    echo
    echo "Resumen rápido de usuarios y carga:"
    echo "========================================"
    # w muestra los usuarios conectados al sistema
    w
}

# Función para terminar todos los procesos en segundo plano
terminar_procesos_en_segundo_plano() {
    echo "Terminando procesos en segundo plano..."
    # Termina todos los procesos en segundo plano
    # jobs -p obtiene los PIDs de todos los procesos en segundo plano
    # xargs -r kill envía una señal de terminación a cada PID obtenido
    # -r evita que xargs ejecute kill si no hay PIDs
    jobs -p | xargs -r kill
    echo "Todos los procesos en segundo plano han sido terminados."
}

mostrar_menu() {
    echo
    echo "=================================="
    echo "MENÚ"
    echo "=================================="
    echo "1) Mostrar procesos activos"
    echo "2) Buscar proceso por nombre"
    echo "3) Administrar proceso por PID (ver detalles y terminar)"
    echo "4) Mostrar procesos en segundo plano"
    echo "5) Enviar señales"
    echo "6) Mostrar promedio de carga"
    echo "7) Terminar procesos en segundo plano"
    echo "0) Salir"
    echo "=================================="
}

# Bucle para mostrar menú de opciones
while true; do
    mostrar_menu
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) mostrar_procesos ;;
        2) buscar_proceso ;;
        3) administrar_proceso ;;
        4) mostrar_procesos_segundo_plano ;;
        5) enviar_senales ;;
        6) mostrar_carga ;;
        7) terminar_procesos_en_segundo_plano ;;
        0) echo "Saliendo del ejercicio..."; break ;;
        *) echo "Opción inválida. Inténtelo otra vez." ;;
    esac
done