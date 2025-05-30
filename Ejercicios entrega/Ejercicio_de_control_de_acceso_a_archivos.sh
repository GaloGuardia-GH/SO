#!/bin/bash

dir="$HOME/practica_permisos"
mkdir -p "$dir"

# Verifica si el archivo ya existe
existe_archivo() {
    # -f verifica si es un archivo
    if [[ -f "$dir/$1" ]]; then
        return 0
    else
        return 1
    fi
}

# Verifica si el directorio ya existe
existe_directorio() {
    # -d verifica si es un directorio
    if [[ -d "$dir/$1" ]]; then
        return 0
    else
        return 1
    fi
}

crear_archivo() {
    if ! existe_archivo; then
        touch "$dir/$1"
        echo "Archivo $1 creado en $dir."
    else
        echo "El archivo $1 ya existe en $dir."
    fi
}

crear_directorio() {
    if ! existe_directorio; then
        mkdir "$dir/$1"
        echo "Directorio $1 creado en $dir."
    else
        echo "El directorio $1 ya existe en $dir."
    fi
}

crear_archivo_directorio() {
    read -p "Ingrese el nombre del archivo / directorio a crear: " nombre
    read -p "Desea crear un archivo (A) o un directorio (D)? " tipo

    if [[ -z "$nombre" ]]; then
        echo "Debe proporcionar un nombre para el archivo / directorio."
        return
    fi

    if [[ "$tipo" == "A" ]]; then
        crear_archivo "$nombre"
    elif [[ "$tipo" == "D" ]]; then
        crear_directorio "$nombre"
    else
        echo "Opción inválida."
    fi
}

ver_permisos() {
    read -p "Ingrese el nombre del archivo / directorio: " nombre

    if [[ -z "$nombre" ]]; then
        echo "Debe proporcionar un nombre para el archivo / directorio."
        return
    fi

    # Verifica si el archivo / directorio existe
    if ! (existe_archivo "$nombre" || existe_directorio "$nombre"); then
        echo "El archivo / directorio $nombre no existe en $dir."
        return
    fi

    echo "Permisos de $nombre: "
    # Muestra los permisos del archivo / directorio
    ls -ld "$dir/$nombre"
}

cambiar_permisos_numerico() {
    read -p "Ingresa el nombre del archivo / directorio: " nombre
    read -p "Ingresa el modo numérico (ej: 644, 755): " modo

    if [[ -z "$nombre" || -z "$modo" ]]; then
        echo "Debe proporcionar un nombre y un modo numérico."
        return
    fi

    # Verifica si el archivo / directorio existe
    if ! (existe_archivo "$nombre" || existe_directorio "$nombre"); then
        echo "El archivo / directorio $nombre no existe en $dir."
        return
    fi

    # Verifica que el modo sea un número válido
    if ! [[ "$modo" =~ ^[0-7]{3,4}$ ]]; then
        echo "Modo numérico inválido. Debe ser un número de 3 o 4 dígitos."
        return
    fi

    chmod "$modo" "$dir/$nombre"
    echo "Permisos cambiados a $modo."
    ls -ld "$dir/$nombre"
}

cambiar_permisos_simbolico() {
    read -p "Ingresa el nombre del archivo / directorio: " nombre
    read -p "Ingresa el permiso simbólico (ej: u+x, g-w): " simb

    if [[ -z "$nombre" || -z "$simb" ]]; then
        echo "Debe proporcionar un nombre y un modo numérico."
        return
    fi

    # Verifica si el archivo / directorio existe
    if ! (existe_archivo "$nombre" || existe_directorio "$nombre"); then
        echo "El archivo / directorio $nombre no existe en $dir."
        return
    fi

    # Verifica que el permiso simbólico sea válido
    if ! [[ "$simb" =~ ^[ugoa]*[+-=][rwxXst]*$ ]]; then
        echo "Permiso simbólico inválido. Debe seguir el formato correcto."
        return
    fi

    chmod "$simb" "$dir/$nombre"
    echo "Permisos cambiados simbólicamente."
    ls -ld "$dir/$nombre"
}

cambiar_propietario() {
    # Verifica si el script se está ejecutando como root
    # Para cambiar el propietario de un archivo o directorio, se necesita permisos de superusuario
    # id -u devuelve el ID de usuario del usuario actual; 0 es el ID de root
    if [ "$(id -u)" -ne 0 ]; then
        echo "Este script debe ejecutarse como root para cambiar el propietario de archivos o directorios."
        exit 1
    fi

    read -p "Ingresa el nombre del archivo / directorio: " nombre
    read -p "Ingresa el nuevo propietario (usuario): " usuario

    if [[ -z "$nombre" || -z "$usuario" ]]; then
        echo "Debe proporcionar un nombre y un usuario."
        return
    fi

    # Verifica si el archivo / directorio existe
    if ! (existe_archivo "$nombre" || existe_directorio "$nombre"); then
        echo "El archivo / directorio $nombre no existe en $dir."
        return
    fi

    # Verifica si el usuario existe
    if ! id -u "$usuario" &>/dev/null; then
        echo "El usuario $usuario no existe."
        return
    fi

    sudo chown "$usuario" "$dir/$nombre"
    echo "Propietario cambiado a $usuario."
    ls -ld "$dir/$nombre"
}

mostrar_y_cambiar_permisos_predeterminados() {
    echo "Permisos predeterminados actuales: $(umask)"

    read -p "Desea modificarlos? (S/N): " resp
    if [[ "$resp" == "S" ]]; then
        read -p "Ingresa el nuevo valor (ej: 022, 077): " nueva_umask

        # Verifica que el valor ingresado sea un número válido
        if ! [[ "$nueva_umask" =~ ^[0-7]{3}$ ]]; then
            echo "Valor de umask inválido. Debe ser un número de 3 dígitos."
            return
        fi

        # Cambia la umask
        # La umask se establece con el comando umask, que afecta a los permisos predeterminados de los archivos y directorios creados
        echo "Cambiando permisos predeterminados a $nueva_umask..."
        umask "$nueva_umask"
        echo "Nuevos permisos predeterminados establecidos: $(umask)"
    else
        echo "Operación cancelada."
    fi
}

eliminar_entorno() {
    read -p "Desea eliminar el entorno de práctica? (S/N): " res

    if [[ "$res" == "S" && -d "$dir" ]]; then
        rm -rf "$dir"
        echo "Entorno eliminado."
    else
        echo "Operación cancelada."
    fi
}

mostrar_menu() {
    echo "=================================="
    echo "MENÚ"
    echo "=================================="
    echo "1) Crear archivo o directorio"
    echo "2) Ver permisos"
    echo "3) Cambiar permisos (modo numérico)"
    echo "4) Cambiar permisos (modo simbólico)"
    echo "5) Cambiar propietario"
    echo "6) Mostrar y cambiar permisos predeterminados"
    echo "7) Eliminar entorno"
    echo "0) Salir"
    echo "=================================="
}

# Bucle para mostrar menú de opciones
while true; do
    mostrar_menu
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) crear_archivo_directorio ;;
        2) ver_permisos ;;
        3) cambiar_permisos_numerico ;;
        4) cambiar_permisos_simbolico ;;
        5) cambiar_propietario ;;
        6) mostrar_y_cambiar_permisos_predeterminados ;;
        7) eliminar_entorno ;;
        0) echo "Saliendo del ejercicio..."; break ;;
        *) echo "Opción inválida. Inténtelo otra vez." ;;
    esac
done