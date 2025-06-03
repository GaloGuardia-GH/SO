#!/bin/bash

BASE_RUN_MEDIA="/run/media/$USER"

# Función para mostrar información sobre dispositivos de bloque
mostrar_dispositivos_bloque() {
    echo "Dispositivos de bloque en /dev:"
    echo "=================================="
    # Listar dispositivos de bloque
    # -l para lista detallada
    # grep 'block' para filtrar dispositivos de bloque
    ls -l /dev | grep 'block'
    echo
    echo "Lista detallada de dispositivos de bloque:"
    echo "=================================="
    # lsblk para mostrar dispositivos de bloque con detalles
    lsblk
}

# Mostrar uso del disco
mostrar_uso_disco() {
    echo "Informe de uso del disco:"
    echo "=================================="
    # df para mostrar uso del disco
    # -h para mostrar en formato legible por humanos
    df -h
}

# Montar un dispositivo
montar_dispositivo() {
    # Verificar si el script se ejecuta como root
    # id -u devuelve el UID del usuario actual, 0 es root
    # -ne significa "no es igual a"
    # Si el UID no es 0, se muestra un mensaje y se sale del script
    if [ "$(id -u)" -ne 0 ]; then
        echo "Este script debe ejecutarse como root."
        return
    fi

    read -p "Ingrese el dispositivo (ej: /dev/sdb1): " dispositivo
    read -p "Ingrese el punto de montaje (ej: /mnt/usb): " punto_montaje

    # Verificar si el dispositivo existe
    if [ ! -b "$dispositivo" ]; then
        echo "El dispositivo $dispositivo no existe o no es un dispositivo de bloque válido."
        return
    fi

    # Verificar si el punto de montaje es un directorio válido
    if [ -z "$punto_montaje" ]; then
        echo "El punto de montaje no puede estar vacío."
        return
    fi

    # Verificar si el punto de montaje ya está montado
    if mountpoint -q "$punto_montaje"; then
        echo "El punto de montaje $punto_montaje ya está montado."
        return
    fi

    # Crear punto de montaje si no existe
    if [ ! -d "$punto_montaje" ]; then
        sudo mkdir -p "$punto_montaje"
        echo "Punto de montaje creado: $punto_montaje"
    fi

    echo "Montando $dispositivo en $punto_montaje..."
    sudo mount "$dispositivo" "$punto_montaje" && echo "Montaje exitoso" || echo "Error al montar"
}

# Desmontar dispositivo
desmontar_dispositivo() {
    # Verificar si el script se ejecuta como root
    # id -u devuelve el UID del usuario actual, 0 es root
    # -ne significa "no es igual a"
    # Si el UID no es 0, se muestra un mensaje y se sale del script
    if [ "$(id -u)" -ne 0 ]; then
        echo "Este script debe ejecutarse como root."
        return
    fi

    read -p "Ingrese el punto de montaje a desmontar (ej: /mnt/usb): " punto_montaje

    # Verificar si el punto de montaje existe
    if [ ! -d "$punto_montaje" ]; then
        echo "El punto de montaje $punto_montaje no existe."
        return
    fi

    # Verificar si el punto de montaje está montado
    if ! mountpoint -q "$punto_montaje"; then
        echo "El punto de montaje $punto_montaje no está montado."
        return
    fi

    echo "=================================="
    echo "Desmontando $punto_montaje..."
    echo "=================================="
    echo "Verificando si hay procesos usando el punto de montaje..."

    # Informar al usuario si hay procesos usando el punto de montaje
    # lsof para listar archivos abiertos por procesos
    # +D para buscar en el directorio dado
    sudo lsof +D "$punto_montaje"
    echo
    echo "Es necesario cerrar todos los procesos que usan $punto_montaje para desmontar correctamente."

    read -p "¿Desea forzar el cierre de procesos y desmontar? (S/N): " respuesta
    if [[ "$respuesta" == "S" ]]; then
        echo "Matando procesos que acceden a $punto_montaje..."
        sudo fuser -km "$punto_montaje"
        echo "Desmontando..."
        sudo umount "$punto_montaje" && echo "Desmontado exitosamente" || echo "Error al desmontar"
    else
        echo "Desmontaje cancelado."
    fi
}

# Mostrar dispositivos extraíbles montados
mostrar_dispositivos_extraibles() {
    # Verificar si el directorio existe y listar su contenido
    if [ ! -d "$BASE_RUN_MEDIA" ]; then
        echo "El directorio $BASE_RUN_MEDIA no existe. Verifique si tiene dispositivos extraíbles montados."
        return
    fi

    if [ -d "$BASE_RUN_MEDIA" ]; then
        echo "Dispositivos extraíbles montados en $BASE_RUN_MEDIA:"
        echo "=================================="
        # Listar dispositivos montados en /run/media/$USER
        # ls para listar archivos y directorios
        # -l para lista detallada
        ls -l "$BASE_RUN_MEDIA"
    else
        echo "El directorio $BASE_RUN_MEDIA no existe o no hay dispositivos extraíbles montados."
    fi
}

# Buscar archivos en un directorio dado
buscar_archivos() {
    read -p "Ingrese el directorio donde buscar (ej: /home/$USER): " dir_buscar
    read -p "Ingrese criterio de búsqueda (ej: *.txt, nombre_exacto, -size +1M): " criterio

    # Verificar si el directorio existe
    if [ ! -d "$dir_buscar" ]; then
        echo "El directorio $dir_buscar no existe."
        return
    fi

    # Verificar si el criterio es válido
    if [[ -z "$criterio" ]]; then
        echo "Criterio de búsqueda no puede estar vacío."
        return
    fi

    # Ejecutar find con el criterio proporcionado
    echo "=================================="
    echo "Resultados de la búsqueda en $dir_buscar:"
    echo "=================================="
    # find para buscar archivos
    # -name para buscar por nombre de archivo
    find "$dir_buscar" -name "$criterio"
}

mostrar_menu() {
    echo
    echo "=================================="
    echo "MENÚ"
    echo "=================================="
    echo "1) Mostrar dispositivos de bloque"
    echo "2) Mostrar uso del disco"
    echo "3) Montar un dispositivo (requiere sudo)"
    echo "4) Desmontar un dispositivo (requiere sudo)"
    echo "5) Mostrar dispositivos extraíbles montados"
    echo "6) Buscar archivos por criterio"
    echo "0) Salir"
    echo "=================================="
}

# Bucle para mostrar menú de opciones
while true; do
    mostrar_menu
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) mostrar_dispositivos_bloque ;;
        2) mostrar_uso_disco ;;
        3) montar_dispositivo ;;
        4) desmontar_dispositivo ;;
        5) mostrar_dispositivos_extraibles ;;
        6) buscar_archivos ;;
        0) echo "Saliendo del ejercicio..."; break ;;
        *) echo "Opción inválida. Inténtelo otra vez." ;;
    esac
done