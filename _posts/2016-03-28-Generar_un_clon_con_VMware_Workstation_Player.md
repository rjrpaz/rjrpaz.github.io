---
layout: post
title:  "Generar un clon con VMware Workstation Player"
date:   2016-03-28 00:00:00 -0300
categories: virtualization ccripting
---

VMWare Workstation Player es una versión free y simplificada de VMWare Workstation Pro. Es un hypervisor de tipo 2, con una interface mucho más sencilla.

Una de las opciones que podemos llegar a extrañar, es que no permite realizar un clonado de una máquina virtual para generar otra.

De cualquier manera, existe una forma relativamente sencilla de realizar un clonado a mano:

1. Copiar el directorio que define una máquina virtual, con un nuevo nombre
2. Dentro de este nuevo directorio, renombrar los archivos, reemplazando las apariciones del nombre original por el nombre nuevo
3. Renombrar las menciones al nombre original en el archivo con extensión .vmx
4. Renombrar las menciones al nombre original en el archivo con extensión .vmxf
5. Renombrar las menciones al nombre original en el archivo con extensión .vmdk

Ejemplo:

```bash

roberto@roberto:~$ cd vmware
roberto@roberto:~/vmware$ ls -l
total 4
drwxr-xr-x 2 roberto roberto 4096 mar 21 21:27 PXEServer
roberto@roberto:~/vmware$ cp -a PXEServer VM1
roberto@roberto:~/vmware$ cd VM1
roberto@roberto:~/vmware/VM1$ rename 's/PXEServer/VM1/' *
roberto@roberto:~/vmware/VM1$ sed -i 's/PXEServer/VM1/g' VM1.vmx
roberto@roberto:~/vmware/VM1$ sed -i 's/PXEServer/VM1/g' VM1.vmxf
roberto@roberto:~/vmware/VM1$ sed -i 's/PXEServer/VM1/g' VM1.vmdk
roberto@roberto:~/vmware/VM1$

```

(“rename” puede llegar a requerir instalación por separado. Es un comando muy útil, así que lo recomiendo ferviertemente).

Cuando ejecutamos VMPlayer, podemos ubicar esta nueva máquina virtual desde la opción “File” -> “Open a Virtual Machine”, y seleccionamos el archivo .vmx de la nueva máquina. A partir de ese momento la nueva máquina virtual aparece listada.

Al arrancar la máquina virtual, VMPlayer se da cuenta que su origen es manual y nos presenta la siguiente pantalla:

![Pregunta si es copiado](/assets/images/Captura-de-pantalla-de-2016-03-21-221754.png)

Elegimos la opción por defecto “I Copied It”. De esta forma, VMPlayer reacomoda los valores necesarios de hardware para que esta nueva máquina virtual no tenga conflictos con la anterior (dirección IP, mac address, etc.)

Si no surgen inconvenientes, estamos en condiciones de poder utilizar simultáneamente ambas máquinas virtuales.

