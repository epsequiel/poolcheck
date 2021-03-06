#!/bin/bash

# Pool Check
# Archivos: pool_check.sh
# Autor:    Ezequiel Meinero
# Fecha:    2018-09-19
# Version:  0.2
#
# Este script revisa el estado de los leases de un determinado pool que introducimos
# como argumento en la llamada.
# Sirve para saber si el pool se completo o quedan ips disponibles.
# Tambien da informacion de como esta funcionando el failover y balanceo.
#
# TODO:
#   1- ipcalc: verificar que el pool de entrada sea un bloque ipv4 valido
#   2- chequear que ese bloque esta declarado en dhcpd.conf
#   3- leer la conf de poolcheck.conf
#   4- cargar la key-ssh para poder consultar el estado del failover ¿hace falta?


IPCALC="/usr/bin/ipcalc"
VERSION="0.2"

#-------------------------------------------------------------------------------
# Colores
#
_VIOLETA="\e[38;5;201m"
_NARANJA="\e[38;5;208m"
_AMARILLO="\e[38;5;226m"
_AZUL="\e[38;5;038m"
_VERDE="\e[38;5;048m"
_ROJO="\e[38;5;196m"
_NC="\e[0m"             # no color


function header() {
    printf "Pool check $VERSION (https://github.com/epsequiel/poolcheck)\n"
}

#-------------------------------------------------------------------------------
# Ayuda
#
function help() {
    # llamada al script
    printf "\n\n$_AMARILLO"
    printf "    Uso:\n"
    printf "        pool_check.sh [hd] -p <bloque>\n"
    printf "\n"
    printf "$_VERDE"
    printf "       +=== pool_check.sh ===+   \n"
    printf "    Este script revisa el estado de los leases de un determinado pool que\n"
    printf "    introducimos como argumento en la llamada.\n"
    printf "    Sirve para saber si el pool se completo o quedan ips disponibles.\n"
    printf "    Tambien da informacion de como esta funcionando el failover y balanceo.\n"
    printf "\n$_NC"
    printf "\t -p <bloque ipv4/prefix> es el bloque del que queremos conocer el estado\n"
    printf "\t -h\tEsta ayuda\n"
    printf "\t -d\tDescripcion de los parametros que se imprimen en el resultado\n"
    printf "\n"
}

function parametros() {
    #
    # total 500  free 388  backup 88  lts -150  max-misbal

    # ---+--- Parametros salida del log ---+---
    # total
    # free
    # backup
    # max-own
    # max-misbal
    # lts
    printf "[+] lts;"
    printf "
        lts = (free - backup) / 2\n"
    printf "\n"

    # ---+--- Parametros configurables en failover.conf ---+---
    # mclt
    printf "[+] mclt seconds;"
    printf "
        The mclt statement defines the Maximum Client  Lead  Time.
        It must be specified on the primary, and may not be speci-
        fied on the secondary.  This is the  length  of  time  for
        which  a  lease  may  be  renewed  by either failover peer
        without contacting the other.\n"
    printf "\n"
    # total
    printf "[+] total;"
    printf "
        Cantidad total de ips disponibles en el pool\n"
    printf "\n"
    # free
    printf "[+] free;"
    printf "
        Cantidad de ips libres en este servidor para ser asignadas\n"
    printf "\n"
    # backup
    printf "[+] backup ips;"
    printf "
        Cantidad de ips libres...\n"
    printf "\n"
    # max-own
    printf "[+] max-own;"
    printf "
        Cantidad de ips libres en este servidor por sobre el failover\n"
    printf "\n"
    # max-misbal
    printf "[+] max-misbal;"
    printf "
        Cantidad de ips libres en este servidor antes de ejecutar un
        balanceo forzado\n"
    printf "\n"
    # split
    printf "[+] split;"
    printf "
        Es un registro de 8 bits y por lo tanto 128 es el valor intermedio
        One form of load balancing where 128 is 50%%/50%% and 256 is 100%%/0%%.\n"
    printf "\n"
    # port
    printf "[+] port;"
    printf "
        TCP port number to listen on for communications from peer.\n"
    printf "\n"

    # peer-port
    printf "[+] peer-port;"
    printf "
        Connect to peer on TCP port.\n"
    printf "\n"

    # load-balance-max-seconds
    printf "[+] load-balance-max-seconds N"
    printf "
        Serve other server's client requests if DHCP header \"SECS\" value is greater than N.\n"
    printf "\n"
    # fuente de la informacion
    printf "[+] Fuentes de info:\n"
    printf "    * http://www.ipamworldwide.com/ipam/dhcp-declare-failover.html\n"
    printf "    * https://source.isc.org/cgi-bin/gitweb.cgi?p=dhcp.git;a=blob;f=server/failover.c\n"
    printf "    * https://github.com/42wim/isc-dhcp/blob/master/server/failover.c\n"
    printf "\n"

}


function get_pool_status() {
    POOL="$1"
    DATA=$(grep "$POOL" /var/log/dhcpd.log | tail -2)

    # printeo toda la info
    printf "\n"
    #printf "%s\n" "---------------------------------------"
    printf "Pool %s status" $POOL
    printf "\n"
    DATE="a"

    # balancing
    BALANCING=$(echo $DATA | awk '{print $6}')

    # pool_hash
    POOL_HASH=$(echo $DATA | awk '{print $8}')

    # pool_ip
    POOL_IP=$(echo $DATA | awk '{print $9}')

    # total_ips
    TOTAL_IPS=$(echo $DATA | awk '{print $11}')

    # free_ips
    FREE_IPS=$(echo $DATA | awk '{print $13}')

    # backup_ips
    BACKUP_IPS=$(echo $DATA | awk '{print $15}')

    # lts
    LTS_PRE=$(echo $DATA | awk '{print $17}')

    # max-own
    MAX_OWN=$(echo $DATA | awk '{print $19}')

    # balanced
    BALANCED=$(echo $DATA | awk '{print $25}')

    # total_post
    TOTAL_POST=$(echo $DATA | awk '{print $30}')

    # free_post
    FREE_POST=$(echo $DATA | awk '{print $32}')

    # backup_ips_post
    BACKUP_IPS_POST=$(echo $DATA | awk '{print $34}')

    # lts_post
    LTS_POST=$(echo $DATA | awk '{print $36}')

    # max_misbal
    MAX_MISBAL=$(echo $DATA | awk '{print $38}')

    printf "\n"
    printf "[*] Pool hash: %s\n" $POOL_HASH
    printf "\n"
    printf "$_NARANJA[*] Balancing: %s\n$_NC" $BALANCING
    printf "$_AZUL[-] Total ips: %d\n$_NC" $TOTAL_IPS
    printf "$_AZUL[-] Free ips: %d\n$_NC" $FREE_IPS
    printf "[-] Backup ips: %d\n" $BACKUP_IPS
    printf "[-] lts: %d\n" $LTS_PRE
    printf "[-] Max-own: %s\n" $MAX_OWN
    printf "[+] ----------------\n"
    printf "\n"
    printf "$_VERDE[*] Balanced: %s\n$_NC" $BALANCED
    printf "$_AZUL[-] Total ips: %d\n$_AZUL" $TOTAL_IPS
    printf "$_AZUL[-] Free ips: %d\n$_NC" $FREE_POST
    printf "[-] Backup ips: %d\n" $BACKUP_IPS_POST
    printf "[-] lts: %d\n" $LTS_POST
    printf "[-] Max-misbal: %d\n" $MAX_MISBAL
    printf "[+] ----------------"
    printf "\n"
}


#-------------------------------------------------------------------------------
# Start
if [[ $# -eq 0 ]]; then     # si no hay parametros muestro la ayuda
    help
    exit 1
fi

LIST_PARM=$@

while getopts ":p:hdv" opt; do
    case $opt in
        p)  # Bloque ip
            header
            POOL=${OPTARG}
            if [ $($IPCALC $POOL | head -1 | cut -f1 -d' ') = "INVALID" ]; then
                printf "Este pool NO es un pool ipv4 VALIDO PAPA!\n\n"
                exit 1
            fi
            get_pool_status ${OPTARG}
            ;;
        h)  # help
            header
            help
            exit 1
            ;;
        d)  # descripcion parametros
            header
            parametros
            exit 1
            ;;
        :)
            echo "Opcion -$OPTARG requiere argumento." >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND-1))
