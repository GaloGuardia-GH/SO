#!/bin/bash

# Verificar si el script se ejecuta como root
# ---------------------------------
# id -u devuelve el UID del usuario actual, 0 es root
# -ne significa "no es igual a"
# Si el UID no es 0, se muestra un mensaje y se sale del script
if [ "$(id -u)" -ne 0 ]; then
    echo "Este script debe ejecutarse como root."
    exit 1
fi

# Función para verificar si existe un usuario
existe_usuario() {
    usuario="$1"
    # id "$usuario" devuelve información del usuario si existe, si no, devuelve un error
    # &>/dev/null redirige tanto la salida estándar como la de error a /dev/null, es decir, no muestra nada en pantalla
    if id "$usuario" &>/dev/null; then
        echo "El usuario '$usuario' existe."
        return 0
    else
        echo "El usuario '$usuario' no existe."
        return 1
    fi
}

# Función para verificar si existe un grupo
existe_grupo() {
    grupo="$1"
    # getent group "$grupo" devuelve información del grupo si existe, si no, devuelve un error
    # &>/dev/null redirige tanto la salida estándar como la de error a /dev/null, es decir, no muestra nada en pantalla
    if getent group "$grupo" > /dev/null; then
        echo "El grupo '$grupo' existe."
        return 0
    else
        echo "El grupo '$grupo' no existe."
        return 1
    fi
}

# Función para crear un usuario
crear_usuario() {
    echo
    echo "Crear nuevo usuario"
    echo "---------------------------------"

    read -p "Ingrese el nombre del usuario: " usuario

    # Verificar si el usuario ya existe
    if ! existe_usuario "$usuario"; then
        # -m: crea automáticamente el directorio /home/nombre_usuario si no existe
        # -s: especifica el shell por defecto del usuario
        echo "Creando usuario '$usuario'..."
        # El comando useradd se usa para crear un nuevo usuario
        # -m: crea el directorio home del usuario si no existe
        # -s: especifica el shell por defecto del usuario
        # Si el usuario ya existe, no se hace nada
        useradd -m -s /bin/bash "$usuario"
        # El comando passwd se usa para establecer la contraseña del usuario
        passwd "$usuario"
        echo "Usuario '$usuario' creado con éxito."
    fi
}

# Función para mostrar información de un usuario
mostrar_informacion_usuario() {
    echo
    echo "Mostrar información de un usuario"
    echo "---------------------------------"

    read -p "Ingrese el nombre del usuario: " usuario

    # Verificar si el usuario existe
    if existe_usuario "$usuario"; then
        # El comando id muestra información del usuario, incluyendo UID, GID y grupos a los que pertenece
        id "$usuario"
        # El comando groups muestra los grupos a los que pertenece el usuario
        groups "$usuario"
    fi
}

# Función para asignar un usuario a un grupo
asignar_usuario_a_grupo() {
    echo
    echo "Asignar usuario a un grupo"
    echo "---------------------------------"

    read -p "Ingrese el nombre del usuario: " usuario
    read -p "Ingrese el nombre del grupo: " grupo

    if existe_usuario "$usuario" && existe_grupo "$grupo"; then
        echo "Asignando usuario '$usuario' al grupo '$grupo'..."
        # El comando usermod se usa para modificar un usuario existente
        # -a: agrega el usuario al grupo sin eliminarlo de otros grupos
        # -G: especifica el grupo al que se va a agregar el usuario
        # Si el usuario ya está en el grupo, no se hace nada
        usermod -aG "$grupo" "$usuario"
        echo "Usuario '$usuario' asignado al grupo '$grupo' con éxito."
    fi
}

# Función para cambiar la contraseña de un usuario
cambiar_contrasena_usuario() {
    echo
    echo "Cambiar contraseña de un usuario"
    echo "---------------------------------"

    read -p "Ingrese el nombre del usuario: " usuario

    # Verificar si el usuario existe
    if existe_usuario "$usuario"; then
        # El comando passwd se usa para cambiar la contraseña de un usuario
        passwd "$usuario"
        echo "Contraseña del usuario '$usuario' cambiada con éxito."
    fi
}

# Función para eliminar un usuario
eliminar_usuario() {
    echo
    echo "Eliminar un usuario"
    echo "---------------------------------"

    read -p "Ingrese el nombre del usuario: " usuario

    if existe_usuario "$usuario"; then
        echo "Eliminando usuario '$usuario'..."
        # El comando userdel se usa para eliminar un usuario
        # -r: elimina el directorio home del usuario y su contenido
        userdel -r "$usuario"
        echo "Usuario '$usuario' eliminado con éxito."
    fi
}

# Función para mostrar las opciones de funciones de usuarios
mostrar_funciones_usuarios() {
    echo
    echo "=============================="
    echo "FUNCIONES DE USUARIOS"
    echo "=============================="
    echo "1) Crear un usuario"
    echo "2) Mostrar información de un usuario"
    echo "3) Asignar un usuario a un grupo"
    echo "4) Cambiar contraseña de un usuario"
    echo "5) Eliminar un usuario"
    echo "0) Volver al menú principal"
    echo "=============================="
}

# Función para acceder a las funciones de usuarios
acceder_funciones_usuarios() {
    while true; do
        mostrar_funciones_usuarios
        read -p "Selecciona una opción: " opcion

        case $opcion in
            1) crear_usuario ;;
            2) mostrar_informacion_usuario ;;
            3) asignar_usuario_a_grupo ;;
            4) cambiar_contrasena_usuario ;;
            5) eliminar_usuario ;;
            0) break ;;
            *) echo "Opción inválida. Inténtelo otra vez." ;;
        esac
    done
}

# Función para crear un grupo
crear_grupo() {
    echo
    echo "Crear nuevo grupo"
    echo "---------------------------------"

    read -p "Ingrese el nombre del grupo: " grupo

    # Verificar si el grupo ya existe
    if ! existe_grupo "$grupo"; then
        echo "Creando grupo '$grupo'..."
        # El comando groupadd se usa para crear un nuevo grupo
        # Si el grupo ya existe, no se hace nada
        groupadd "$grupo"
        echo "Grupo '$grupo' creado con éxito."
    fi
}

# Función para mostrar información de un grupo
mostrar_informacion_grupo() {
    echo
    echo "Mostrar información de un grupo"
    echo "---------------------------------"

    read -p "Ingrese el nombre del grupo: " grupo

    if existe_grupo "$grupo"; then
        # getent group devuelve la información del grupo, incluyendo los usuarios asignados
        getent group "$grupo"
        echo
        # Para obtener solo los usuarios asignados al grupo, usamos cut.
        # La salida se separa por comas, así que usamos cut para obtener solo los usuarios
        # -d: especifica el delimitador, en este caso ':'
        # -f4: obtiene el cuarto campo, que es la lista de usuarios
        echo "Usuarios asignados al grupo '$grupo':"
        getent group "$grupo" | cut -d: -f4
    fi
}

# Función para desasignar un usuario de un grupo
desasignar_usuario_de_grupo() {
    echo
    echo "Desasignar un usuario de un grupo"
    echo "---------------------------------"

    read -p "Ingrese el nombre del usuario: " usuario
    read -p "Ingrese el nombre del grupo: " grupo

    if existe_usuario "$usuario" && existe_grupo "$grupo"; then
        echo "Desasignando usuario '$usuario' del grupo '$grupo'..."
        # El comando gpasswd se usa para modificar la membresía de un grupo
        # -d: elimina al usuario del grupo especificado
        gpasswd -d "$usuario" "$grupo"
        echo "Usuario '$usuario' desasignado del grupo '$grupo' con éxito."
    fi
}

# Función para eliminar un grupo
eliminar_grupo() {
    echo
    echo "Eliminar un grupo"
    echo "---------------------------------"

    read -p "Ingrese el nombre del grupo: " grupo

    if existe_grupo "$grupo"; then
        echo "Eliminando grupo '$grupo'..."
        # El comando groupdel se usa para eliminar un grupo
        # Si el grupo tiene usuarios asignados, se eliminará solo si no hay usuarios en él
        # Si hay usuarios asignados, se mostrará un error
        groupdel "$grupo"
        echo "Grupo '$grupo' eliminado con éxito."
    fi
}

# Función para mostrar las opciones de funciones de grupos
mostrar_funciones_grupos() {
    echo
    echo "=============================="
    echo "FUNCIONES DE GRUPOS"
    echo "=============================="
    echo "1) Crear un grupo"
    echo "2) Mostrar información de un grupo"
    echo "3) Asignar un usuario a un grupo"
    echo "4) Desasignar un usuario de un grupo"
    echo "5) Eliminar un grupo"
    echo "0) Volver al menú principal"
    echo "=============================="
}

# Función para acceder a las funciones de grupos
acceder_funciones_grupos() {
    while true; do
        mostrar_funciones_grupos
        read -p "Selecciona una opción: " opcion

        case $opcion in
            1) crear_grupo ;;
            2) mostrar_informacion_grupo ;;
            3) asignar_usuario_a_grupo ;;
            4) desasignar_usuario_de_grupo ;;
            5) eliminar_grupo ;;
            0) break ;;
            *) echo "Opción inválida. Inténtelo otra vez." ;;
        esac
    done
}

# Función para crear un directorio compartido
crear_directorio_compartido() {
    echo
    echo "Crear directorio compartido"
    echo "---------------------------------"

    read -p "Ingrese el nombre del directorio: " dir_nombre
    read -p "Ingrese el grupo al que se asignará el directorio: " grupo

    if existe_grupo "$grupo"; then
        # Crear el directorio si no existe
        mkdir -p "/home/$dir_nombre"
        echo "Directorio '/home/$dir_nombre' creado."

        # Cambiar el grupo del directorio
        chown :$grupo "/home/$dir_nombre"
        echo "Grupo del directorio cambiado a '$grupo'."

        # Establecer permisos para que el grupo tenga acceso completo
        # Permisos 770: propietario y grupo tienen permisos de lectura, escritura y ejecución; otros no tienen permisos
        chmod 770 "/home/$dir_nombre"
        echo "Permisos del directorio establecidos para el grupo '$grupo'."
    fi
}

# Función para mostrar el menú de opciones
mostrar_menu() {
    echo
    echo "=============================="
    echo "MENÚ"
    echo "=============================="
    echo "1) Funciones de usuarios"
    echo "2) Funciones de grupos"
    echo "3) Crear directorio compartido"
    echo "0) Salir"
    echo "=============================="
}

# Bucle para mostrar menú de opciones
while true; do
    mostrar_menu
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) acceder_funciones_usuarios ;;
        2) acceder_funciones_grupos ;;
        3) crear_directorio_compartido ;;
        0) echo "Saliendo del ejercicio..."; break ;;
        *) echo "Opción inválida. Inténtelo otra vez." ;;
    esac
done