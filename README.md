# poolcheck

Este script busca en los logs de isc-dhcp informacion sobre el estado del cluster failover y del pool que introducimos como parámetro.
Nos devuelve el estado del servidor y la cantidad de ips totales, libres  y backup.

## USO

    pool_check.sh -[hdv] -b <bloque de interes>

    -p <bloque ipv4/prefix> es el bloque del que queremos conocer el estado 
    -h     Esta ayuda
    -d     Descripcion de los parametros que se imprimen en el resultado
    

```
dhcpvoip # ./pool_check.sh -b 10.8.4.0/24


Pool 10.8.4.0/24 status

[*] Balancing: balancing
[-] Pool hash: 7fa8d2d0bfd0
[-] Total ips: 244
[-] Free ips: 85
[-] Backup ips: 130
[-] lts: -22
[-] Max-own: (+/-)22
[+] ----------------

[*] Balanced: balanced
[-] Total ips: 244
[-] Free ips: 85
[-] Backup ips: 130
[-] lts: -22
[-] Max-misbal: 32
[+] ----------------
```

## TODO
- [x] 1. ipcalc: verificar que el pool de entrada sea un bloque ipv4 valido
- [ ] 2. chequear que ese bloque esté declarado en dhcpd.conf
- [ ] 3. leer la conf desde poolcheck.conf
- [ ] 4. cargar la key-ssh para poder consultar el estado del failover ¿hace falta?
- [ ] 5. revisar los fuentes de isc-dhcp para comprender cada uno de los parametros


