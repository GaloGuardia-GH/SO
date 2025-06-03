#!/bin/bash

# Variables de configuración
ORIGEN="$HOME/Documentos/archivos_ejemplo" # Directorio de origen para el backup
DESTINO="$HOME/backups" # Directorio de destino para el backup
FECHA=$(date +"%Y%m%d_%H%M%S") # Fecha y hora actual para el nombre del archivo
ARCHIVO_BACKUP="backup_$FECHA.tar.gz" # Nombre del archivo de backup
SERVIDOR_REMOTO="$(whoami)@192.168.1.100" # Dirección del servidor remoto
RUTA_REMOTA="/home/usuario/backup_remoto" # Ruta en el servidor remoto para almacenar el backup
DIRECTORIO_REMOTO="/home/usuario/sincronizado" # Directorio remoto para sincronizar

# Crear directorio de origen si no existe
mkdir -p "$ORIGEN"

# Crear directorio de backups si no existe
mkdir -p "$DESTINO"

# Función para verificar si un archivo de backup ya existe
existe_archivo_backup() {
    # Verificar si el archivo de backup existe
    if [ -f "$DESTINO/$ARCHIVO_BACKUP" ]; then
        return 0
    else
        echo "No existe el archivo backup creado."
        return 1
    fi
}

# Función para crear un backup de un directorio
crear_backup() {
    # Verificar si el directorio de origen existe
    if [[ ! -d "$ORIGEN" ]]; then
        echo "El directorio de origen '$ORIGEN' no existe."
        return
    fi

    echo "Creando backup..."
    # Crear el backup usando tar
    # -c crea un nuevo archivo tar
    # -z comprime el archivo tar usando gzip
    # -f especifica el nombre del archivo tar a crear
    tar -czf "$DESTINO/$ARCHIVO_BACKUP" "$ORIGEN"
    echo "Backup creado: $DESTINO/$ARCHIVO_BACKUP"
}

# Función para listar el contenido del backup
listar_backup() {
    # Verificar si el archivo de backup existe
    if [ existe_archivo_backup ]; then
        echo "Listando contenido del backup..."
        # Listar el contenido del archivo tar
        # -t lista el contenido del archivo tar
        # -z descomprime el archivo tar usando gzip
        # -f especifica el archivo tar a listar
        tar -tzf "$DESTINO/$ARCHIVO_BACKUP"
    fi
}

# Función para extraer el contenido del backup
extraer_backup() {
    # Verificar si el archivo de backup existe
    if [ existe_archivo_backup ]; then
        # Extracción del contenido del archivo tar
        # Crear un directorio con la fecha actual para la extracción
        # FECHA se usa para crear un directorio único para cada extracción
        EXTRACCION_DIR="$DESTINO/extraccion_$FECHA"

        # Crear un directorio para la extracción
        # -p crea el directorio y sus padres si no existen
        mkdir -p "$EXTRACCION_DIR"

        echo "Extrayendo contenido del backup en: $EXTRACCION_DIR"
        # Extraer el contenido del archivo tar
        # -x extrae el contenido del archivo tar
        # -z descomprime el archivo tar usando gzip
        # -f especifica el archivo tar a extraer
        tar -xzf "$DESTINO/$ARCHIVO_BACKUP" -C "$EXTRACCION_DIR"
        echo "Contenido extraído en: $EXTRACCION_DIR"
    fi
}

# Función para transferir el backup con SCP
transferir_backup_scp() {
    # Verificar si el archivo de backup existe
    if [ existe_archivo_backup ]; then
        echo "Transfiriendo backup con SCP..."
        # scp es una herramienta para copiar archivos entre sistemas locales y remotos
        scp "$DESTINO/$ARCHIVO_BACKUP" "$SERVIDOR_REMOTO:$RUTA_REMOTA"
    fi
}

transferir_backup_sftp() {
    # Verificar si el archivo de backup existe
    if [ existe_archivo_backup ]; then
        echo "Transfiriendo backup con SFTP..."
        # sftp es una herramienta para transferir archivos de forma segura entre sistemas locales y remotos
        # put se usa para subir un archivo al servidor remoto
        # <<< se usa para enviar comandos directamente a sftp
        sftp "$SERVIDOR_REMOTO":"$RUTA_REMOTA" <<< "put $DESTINO/$ARCHIVO_BACKUP"
    fi
}

# Función para transferir el backup a un servidor remoto
transferir_backup() {
    echo "1) Transferir backup con SCP"
    echo "2) Transferir backup con SFTP"
    read -p "Seleccione una opción [1-2]: " opcion

    case $opcion in
        1) transferir_backup_scp ;;
        2) transferir_backup_sftp ;;
        *) echo "Opción inválida.";;
    esac
}

# Función para obtener el tamaño del archivo local
tamaño_local() {
    echo "Obteniendo tamaño del archivo local..."
    # stat es una herramienta para mostrar información sobre archivos
    # -c%s devuelve el tamaño del archivo en bytes
    stat -c%s "$DESTINO/$ARCHIVO_BACKUP"
}

# Función para obtener el tamaño del archivo remoto
tamaño_remoto() {
    echo "Obteniendo tamaño del archivo remoto..."
    # Usar ssh para ejecutar un comando remoto que obtenga el tamaño del archivo
    # -c%s devuelve el tamaño del archivo en bytes
    ssh "$SERVIDOR_REMOTO" "stat -c%s $RUTA_REMOTA/$ARCHIVO_BACKUP"
}

# Función para verificar la integridad del backup comparando tamaños
verificar_integridad() {
    # Verificar si el archivo de backup local existe
    if [ ! existe_archivo_backup ]; then
        echo "No se puede verificar la integridad: el archivo de backup no existe."
        return
    fi

    # Verificar si el servidor remoto y la ruta remota están configurados
    if [[ -z "$SERVIDOR_REMOTO" || -z "$RUTA_REMOTA" ]]; then
        echo "Debe configurar el servidor remoto y la ruta remota."
        return
    fi

    # Verificar si el archivo de backup remoto existe
    # ssh se usa para ejecutar un comando remoto
    # test -f verifica si un archivo existe y es un archivo regular
    if ! ssh "$SERVIDOR_REMOTO" "test -f $RUTA_REMOTA/$ARCHIVO_BACKUP"; then
        echo "Error: el archivo de backup remoto no existe."
        return
    fi

    echo "Verificando integridad del backup..."
    echo "==================================="
    echo "Obteniendo tamaños de los archivos..."
    # Llamar a las funciones para obtener los tamaños y almacenarlos en variables
    # tamaño_local obtiene el tamaño del archivo local
    # tamaño_remoto obtiene el tamaño del archivo remoto
    local_size=$(tamaño_local)
    remote_size=$(tamaño_remoto)

    if [ -z "$local_size" ] || [ -z "$remote_size" ]; then
        echo "Error: no se pudo obtener el tamaño de uno o ambos archivos."
        return
    fi

    echo "Tamaño local: $local_size bytes"
    echo "Tamaño remoto: $remote_size bytes"

    echo "==================================="
    # Comparar los tamaños de los archivos local y remoto
    # Si los tamaños son iguales y no son cero, la verificación es exitosa
    # -eq compara si los dos valores son iguales
    # -ne compara si los dos valores son diferentes
    # -ne 0 verifica que el tamaño no sea cero (es decir, el archivo no está vacío)
    echo "Comparando tamaños..."
    if [ "$local_size" -eq "$remote_size" ] && [ "$local_size" -ne 0 ]; then
        echo "Verificación exitosa: tamaños coinciden."
    else
        echo "Error: tamaños no coinciden o el archivo remoto no existe."
    fi
}

# Función para sincronizar directorios con un servidor remoto
sincronizar_directorios() {
    # Verificar si el directorio de origen existe
    if [[ ! -d "$ORIGEN" ]]; then
        echo "El directorio de origen '$ORIGEN' no existe."
        return
    fi

    # Verificar si el directorio remoto existe
    if [[ -z "$SERVIDOR_REMOTO" || -z "$DIRECTORIO_REMOTO" ]]; then
        echo "Debe configurar el servidor remoto y el directorio remoto."
        return
    fi

    echo "Sincronizando $ORIGEN con $SERVIDOR_REMOTO:$DIRECTORIO_REMOTO..."
    # rsync es una herramienta para sincronizar archivos y directorios entre sistemas locales y remotos
    # -a preserva los permisos, tiempos de modificación, etc.
    # -v muestra información detallada del proceso
    # -z comprime los datos durante la transferencia
    # --delete elimina archivos en el destino que no están en el origen
    rsync -avz --delete "$ORIGEN/" "$SERVIDOR_REMOTO:$DIRECTORIO_REMOTO/"
}

mostrar_menu() {
    echo
    echo "=================================="
    echo "MENÚ"
    echo "=================================="
    echo "1) Crear backup"
    echo "2) Listar contenido del backup"
    echo "3) Extraer contenido del backup"
    echo "4) Transferir backup"
    echo "5) Verificar integridad (tamaño local vs remoto)"
    echo "6) Sincronizar directorios"
    echo "0) Salir"
    echo "=================================="
}

# Bucle para mostrar menú de opciones
while true; do
    mostrar_menu
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) crear_backup ;;
        2) listar_backup ;;
        3) extraer_backup ;;
        4) transferir_backup ;;
        5) verificar_integridad ;;
        6) sincronizar_directorios ;;
        0) echo "Saliendo del ejercicio..."; break ;;
        *) echo "Opción inválida. Inténtelo otra vez." ;;
    esac
done