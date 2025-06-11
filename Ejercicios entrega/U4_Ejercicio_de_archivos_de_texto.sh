#!/bin/bash

ARCHIVO=""

# Función para crear un nuevo archivo de texto
crear_archivo() {
    echo
    echo "Crear nuevo archivo de texto"
    echo "---------------------------------"

    read -p "Nombre del archivo (sin espacios): " nombre

    # Declarar la variable ARCHIVO como global
    declare -g ARCHIVO="${nombre}.txt"

    # Verificar si la variable está vacía
    if [[ -z "$ARCHIVO" ]]; then
        echo "Nombre inválido. Intenta de nuevo."
        return
    fi

    # Verificar si el archivo ya existe
    if [[ -f "$ARCHIVO" ]]; then
        echo "El archivo '$ARCHIVO' ya existe."
        read -p "Desea sobrescribirlo? (S/N): " resp
        [[ "$resp" != "S" ]] && echo "Operación cancelada." && return
    fi

    echo
    echo "(*) Escribe el contenido del archivo línea por línea."
    echo "(*) Escribe 'FIN' en una línea para terminar."
    echo

    # Entrada de contenido
    contenido=""
    while true; do
        read -p "> " linea
        [[ "$linea" == "FIN" ]] && break
        contenido+="$linea"$'\n'
    done

    echo
    echo "Vista previa del contenido:"
    echo "---------------------------------"
    echo "$contenido"
    echo "---------------------------------"
    echo

    read -p "Desea guardar este contenido en '$ARCHIVO'? (S/N): " confirmar
    if [[ "$confirmar" == "S" ]]; then
        # echo añade un salto de línea al final, con -n no se agrega este salto
        echo -n "$contenido" > "$ARCHIVO"
        echo "Archivo '$ARCHIVO' creado con éxito."
        # Se llama a la función mostrar_contenido para mostrar el contenido del archivo
        mostrar_contenido
    else
        echo "Archivo no guardado."
    fi
}

# Función para buscar y reemplazar texto en el archivo
buscar_y_reemplazar() {
    echo
    echo "Buscar y reemplazar texto en el archivo"
    echo "---------------------------------"

    # Validar si el archivo existe
    if [[ ! -f "$ARCHIVO" ]]; then
        echo "El archivo '$ARCHIVO' no existe."
        echo
        read -p "Desea crear un archivo? (S/N): " resp
        if [[ "$resp" == "S" ]]; then
            crear_archivo
        else
            echo "Operación cancelada."
            return
        fi
    fi

    echo
    read -p "Palabra a buscar: " buscar
    read -p "Reemplazar por: " reemplazo

    echo
    # Preguntar si se desea crear un backup
    read -p "Desea crear un archivo backup? (S/N): " resp
    [[ "$resp" == "S" ]] && crear_backup

    # Reemplazo automático usando Vim
    vim "$ARCHIVO" -c ":%s/$buscar/$reemplazo/g" -c ":wq"

    cambio="Se reemplazó '$buscar' por '$reemplazo'"

    echo
    # Se llama a la función guardar_log para registrar la operación
    guardar_log "$buscar" "$reemplazo" "$cambio"
}

# Función para crear un backup del archivo
crear_backup() {
    # Crear copia de respaldo
    BACKUP="${ARCHIVO}.bak"
    # El comando cp copia el archivo original al archivo de backup
    # Si el archivo de backup ya existe, lo sobrescribe
    cp "$ARCHIVO" "$BACKUP"
    echo "Copia de seguridad creada: $BACKUP"
}

# Función para guardar el log de las operaciones
guardar_log() {
    # Guardar en log
    echo "Registrando en log.txt..."
    {
        echo "--------------------------------------------"
        echo "(*) Fecha: $(date)"
        echo "(*) Usuario: $(whoami)"
        echo "(*) Archivo: $ARCHIVO"
        echo "(*) Acción: Reemplazo automático"
        echo "(*) Buscar: $2"
        echo "(*) Reemplazar por: $3"
        echo "(*) Resultado: $4"
    } >> log.txt

    echo "Operación registrada en 'log.txt'"
}

# Función para agregar encabezado y lista personalizada al archivo
agregar_contenido() {
    echo
    echo "Agregar encabezado y lista personalizada"
    echo "---------------------------------"

    # Validar si el archivo existe
    if [[ ! -f "$ARCHIVO" ]]; then
        echo "El archivo '$ARCHIVO' no existe."
        echo
        read -p "Desea crear un archivo? (S/N): " resp
        if [[ "$resp" == "S" ]]; then
            crear_archivo
        else
            echo "Operación cancelada."
            return
        fi
    fi

    echo
    read -p "Título del encabezado: " encabezado

    echo
    echo "(*) Escribir los ítems de la lista (uno por línea)."
    echo "(*) Finaliza con una línea vacía"
    echo

    # Crear lista para almacenar los ítems
    lista=()
    while true; do
        read -p "- " item
        [[ -z "$item" ]] && break
        lista+=("- [ ] $item")
    done

    # echo -e hace que echo interprete los caracteres especiales como \n (nueva línea)
    # echo añade un salto de línea al final, con -n no se agrega este salto
    echo -ne "\n${encabezado^^}\n" >> "$ARCHIVO"
    echo "=====================================================" >> "$ARCHIVO"

    # Añadir la lista de ítems al archivo
    for i in "${lista[@]}"; do
        echo "$i" >> "$ARCHIVO"
    done

    echo "Lista añadida al final del archivo."
}

# Función para mostrar el menú principal
mostrar_menu() {
    echo
    echo "=============================="
    echo "MENÚ"
    echo "=============================="
    echo "1) Crear o editar archivo"
    echo "2) Editar archivo con VIM"
    echo "3) Buscar y reemplazar texto"
    echo "4) Añadir encabezado y lista"
    echo "6) Ver contenido actual"
    echo "7) Mostrar ayuda de comandos"
    echo "0) Salir"
    echo "=============================="
}

# Mostrar contenido del archivo
mostrar_contenido() {
    echo
    echo "CONTENIDO DEL ARCHIVO"
    echo "----------------------------------"
    # El comando cat muestra el contenido del archivo
    cat "$ARCHIVO"
    echo "----------------------------------"
}

# Mostrar ayuda de comandos de Vim
mostrar_ayuda() {
    echo
    echo "COMANDOS VIM"
    echo "---------------------------------------------------"
    echo "i                 -> Insertar texto"
    echo "Esc               -> Salir al modo normal"
    echo ":w                -> Guardar"
    echo ":q                -> Salir"
    echo ":wq               -> Guardar y salir"
    echo ":%s/viejo/nuevo/g -> Reemplazar texto"
    echo "/palabra          -> Buscar palabra"
    echo "n                 -> Ir al siguiente resultado"
    echo "yy | dd | p       -> Copiar | Borrar | Pegar"
    echo "u | Ctrl+R        -> Deshacer | Rehacer"
    echo ":help cmd         -> Ayuda de comandos"
    echo
}

# Bucle para mostrar menú de opciones
while true; do
    mostrar_menu
    read -p "Selecciona una opción: " opcion

    case $opcion in
        1) crear_archivo ;;
        2) echo; ([[ -z "$ARCHIVO" ]] && echo "No se ha generado el archivo.") || (echo "Abriendo archivo con VIM..." && vim "$ARCHIVO") ;;
        3) buscar_y_reemplazar ;;
        4) agregar_contenido ;;
        5) mostrar_contenido ;;
        6) mostrar_ayuda ;;
        0) echo "Saliendo del ejercicio..."; break ;;
        *) echo "Opción inválida. Inténtelo otra vez." ;;
    esac
done