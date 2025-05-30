#!/bin/bash

clear #limpiamos la pantalla

#lo primero que hay que hacer es iniciar sesion en el servidor de la sucursal con ssh
SERVER="" #variable con el nombre del servidor de sucursal
read -p "Ingrese el server de sucursal: " SERVER #ingresamos el valor de la variable SERVER por medio de read...
ssh root@"${SERVER}" "bash -s" < ./scriptb.sh #conectamos con el servidor especificado y luego ejecutamos el segundo script...