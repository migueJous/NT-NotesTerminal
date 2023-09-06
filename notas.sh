#!/bin/bash
clear

#coneccion a la base de datos
notasDb="notasUser.db"
tablaDb="notas"

if [ -f "$notasDb" ]; then
    echo "Base de datos cargada correctamente!"
else
    echo "Se ha creado una nueva base de datos y se ha cargado correctamente!"
    touch "$notasDb"
    sqlite3 "$notasDb" "CREATE TABLE $tablaDb (id INTEGER PRIMARY KEY, titulo TEXT, contenido TEXT)"
fi

#colores y estilo
default="\e[0m"
rojo="\e[31m"
amarillo="\e[33m"
cyan="\e[36m"
blanco="\e[37m"
negro="\e[30m"
verde="\e[32m"
#fondo
bgamarillo="\e[43m"

#funciones operacionales sobre la db
function _verNotasG {

    clear

    _cuenta=$(sqlite3 "$notasDb" "SELECT COUNT(*) FROM notas;")

    if [ $_cuenta -gt 0 ]; then

        _registrosDb=$(sqlite3 "$notasDb" "SELECT * FROM $tablaDb;")

        IFS=$'\n'

        for registro in $_registrosDb; do

            IFS='|' read -ra campos <<< "$registro"
            id="${campos[0]}"
            titulo="${campos[1]}"
            contenido="${campos[2]}"

            echo -e "$rojo \n N°:$cyan $id"
            echo -e "$rojo Titulo:$cyan $titulo"
            echo -e "$rojo Contenido:$cyan $contenido"
            echo -e "$amarillo =======================================$default"

        done

        echo -e "\n"

        read -p " Registros mostrados! presiona enter..."

    else

        echo -e "$verde \nNo tienes ninguna nota guardada aun!"
        read -p " presiona enter para continuar..."

    fi
}

function _crearNuevaN {

    clear
    echo -e "$verde Estas a punto de crear una nueva nota! $default \n"

    read -p " Ingresa el titulo de la nota: " title
    read -p " Ingresa el contenido de la nota: " content

    sqlite3 "$notasDb" "INSERT INTO $tablaDb (titulo, contenido) VALUES ('$title', '$content');"

    if [ $? -eq 0 ]; then

        echo -e "$verde \nLa nota se guardo correctamente!! $default"
        read -p " Presiona enter para continuar..."

    else

        echo -e "$verde \nHa ocurrido un error!!: $? $default"
        read -p " presiona enter para continuar..."

    fi
}

function _editarUnaN {

    clear

    echo -e "$verde Para editar una nota, la identificaras por su N°"
    echo -e " Cuidado elijes mal porque perderas tus notas!! $default \n"

    read -p " Ingresa el N° de la nota a editar: " _numN

    if [ -n "$_numN" ]; then

        _consultarId=$(sqlite3 "$notasDb" "SELECT COUNT(*) FROM $tablaDb WHERE id = $_numN")

        if [ $_consultarId -gt 0 ]; then

            read -p " Ingresa el nuevo titulo: " _newTitle
            read -p " Ingresa el nuevo contenido: " _newContent

            sqlite3 "$notasDb" "UPDATE $tablaDb SET titulo = '$_newTitle', contenido = '$_newContent' WHERE id = $_numN"

            if [ $? -eq 0 ]; then
                echo -e "$verde La nota se ha editado correctamente! $default"
                read -p " Presiona enter para continuar..."

            else

                echo -e "$verde \nHa ocurrido un error!!: $? $default"
                read -p " Presiona enter para continuar..."

            fi

        else

            echo -e "$verde El N° ingresado no pertenece a ninguna nota almacenada!"
            read -p " Presiona enter para continuar..."

        fi

    else

        echo -e "$verdeq No ingresaste un N°!"
        read -p " Presiona enter para continuar..."

    fi

}

function _eliminarUnaN {

    clear

    echo -e "$verde Para editar una nota, la identificaras por su N°"
    echo -e " Cuidado elijes mal porque puedes perder tus notas!!$default\n"

    read -p " Ingresa el N° de la nota a eliminar: " _numN

    if [ -n "$_numN" ]; then

        _consultarId=$(sqlite3 "$notasDb" "SELECT COUNT(*) FROM $tablaDb WHERE id = $_numN")

        if [ $_consultarId -gt 0 ]; then

            sqlite3 "$notasDb" "DELETE FROM $tablaDb WHERE id = $_numN"

            if [ $? -eq 0 ]; then

                echo -e "$verde La nota se elimino correctamente!" 
                read -p " Presiona enter para continuar..."

            else

                echo -e "$verde \nHa ocurrido un error!!: $? $default"
                read -p " presiona enter para continuar..."

            fi

        else

            echo -e "$verde \nEl N° ingresado no pertenece a ninguna nota almacenada!!"
            read -p " Presiona enter para continuar..."

        fi

    else

        echo -e "$verde Debes ingresar un N°!"
        read -p " presiona enter para continuar..."

    fi

}

function _eliminarTodasN {

    clear

    echo -e "$verde Al eliminar todas las notas, se borrara la base de datos, y se formateara una nueva para comenzar a guardar notas nuevas, perderas todas las notas que hayas escrito!! $default\n"
    read -p " Quieres eliminar todas las notas? [si/no]: " _eleccion

    if [ "$_eleccion" == "si" ]; then

        rm $notasDb

        echo -e "$verde Se han eliminado todas las notas, deberas reiniciar el script!"

        exit 1

    elif [ "$_eleccion" == "no" ]; then

        echo -e "$verde Se cancela la eliminacion!"
        read -p " presiona enter para continuar..."

    else

        echo -e "$verde Parece que no sabes que quieres, debes ingresar [si/no]!"
        read -p "presiona enter para continuar..."

    fi

}

function _ayuda {

    clear
    echo -e "\n$cyan Hola! Este es un script de consola que te permite gestionar tus notas permitiendote realizar varias acciones en ellas, este script hace uso de "sqlite" por lo tanto debes instalarlo en tu SO, si estas en debian ejecuta <sudo apt update && apt upgrade -y && apt install sqlite>, este script es completamente funcional de hecho mi intencion es que lo usen las personas que aman la terminal y muy poco usan una interfaz grafica o no la tienen, en fin no tengo mucho que explicsr sobre su uso ya que es algo simple y a la vez intuitivo, lee con atencion...(si encuentras algun error en el codigo o un error de ortografia informame, lo corregire)\n"
    echo -e "$rojo Mi web:$cyan https://miguejous.surge.sh/"
    echo -e "$rojo Mi blog:$cyan https://miguejous.blogspot.com/"
    echo -e "$rojo Mi github:$cyan https://github.com/migueJous\n"
    echo -e "$cyan Si quieres apoyarme, en mi web esta un enlace a paypal, buscalo! $default\n"
    read -p " Todo listo? presiona enter..."

}

while [ true ]; do

    clear

    echo -e "$negro $bgamarillo NT-NotesTerminal v0.0.50$default\n"

    echo -e "$amarillo [0]$blanco >$cyan Ver las notas guardadas"
    echo -e "$amarillo [1]$blanco >$cyan Crear una nueva nota"
    echo -e "$amarillo [2]$blanco >$cyan Editar una nota"
    echo -e "$amarillo [3]$blanco >$cyan Eliminar una nota"
    echo -e "$amarillo [4]$blanco >$cyan Eliminar todas las notas"
    echo -e "$amarillo [5]$blanco >$cyan Ayuda-informacion"
    echo -e "$amarillo [6]$blanco >$cyan Salir$default\n"

    read -p " Que quieres hacer?: " opcionPrincipal

    if [ $opcionPrincipal == "0" ]; then

        _verNotasG

    elif [ $opcionPrincipal == "1" ]; then

        _crearNuevaN

    elif [ $opcionPrincipal == "2" ]; then

        _editarUnaN

    elif [ $opcionPrincipal == "3" ]; then

        _eliminarUnaN

    elif [ $opcionPrincipal == "4" ]; then

        _eliminarTodasN

    elif [ $opcionPrincipal == "5" ]; then

        _ayuda

    elif [ $opcionPrincipal == "6" ]; then

        echo -e "$rojo Hasta pronto!..."
        break

    else

        read -p "Ingresa una opcion valida!! presiona enter..."

    fi

done


#Script desarrollado por Miguel José Otero Garcia
#blog: https://miguejous.blogspot.com/
#web: https://miguejous.surge.sh/
#github: https://github.com/migueJous


#Hecho desde mi android porque me quede sin pc, pero
#no me quede sin ganas de programar ❤️...
