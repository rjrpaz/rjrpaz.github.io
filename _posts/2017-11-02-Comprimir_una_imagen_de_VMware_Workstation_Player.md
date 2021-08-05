---
layout: post
title:  "Comprimir una imagen de VMware Workstation Player"
date:   2017-11-02 00:00:00 -0300
categories: virtualization
---

A veces deseamos almacenar una imagen de  Workstation Player en la que hayamos estado trabajando (un prueba o un proyecto que ya no necesitemos, por ejemplo).

La mejor forma de liberar el espacio, es almacenar la imagen comprimida.

El proceso de compresión debería seguir algunos pasos:

1. Hacer espacio dentro de la imagen, con herramientas propias del sistema operativo.
1. Instalar el defragmentador de disco que provee VMWare.
1. Ejecutar el defragmentador de disco que provee VMWare.
1. Finalmente, comprimir la imagen con algún compresor.

## Hacer espacio en la imagen con las herramientas que provee el sistema operativo virtual.

En este ejemplo, el sistema operativo virtual es CentOS 7.

Existen muchos comandos que podríamos ejecutar para realizar limpieza, y varía
según las aplicaciones que estén instaladas, si queremos mantener los archivos
de log, la información de la base de datos, etc.

A modo de ejemplo, el único comando que voy a ejecutar es limpiar el caché del
gestor de paquetes del sistema operativo

Ejemplo:

```console
root@localhost:~$ yum clean all
```

![Yum clean all](/assets/images/2017-11-02-01.png)

## Defragmentar el disco de la imagen con las herramientas que provee VMWare.

VMWare provee comandos que permiten defragmentar el sistema operativo emulado.
En el caso de Linux, y dependiendo de la distribución utilizada, puede que estas
herramientas sean instalables desde el mismo gestor de paquetes del sistema operativo,
o bien deban ser instaladas a mano.

### En el caso de que sean instalables desde el gestor de paquetes:

```console
root@localhost:~$ yum install open-vm-tools
```

### Para instalarlo a mano, debemos ejecutar

![Instalar open-vm-tools](/assets/images/2017-11-02-02.png)

![Instalar open-vm-tools](/assets/images/2017-11-02-03.png)

En este punto, disponemos de un media de instalación virtual listo para ser utilizado
en el sistema emulado:

```console
root@localhost:~$ mount /dev/cdrom /mnt
```

![Instalar open-vm-tools](/assets/images/2017-11-02-04.png)

Nos posicionamos en algún sitio donde podamos descomprimir el archivo con las herramientas:

```console
root@localhost:~$ cd /tmp
root@localhost: tmp$ tar zxvf /mnt/VMwareTools-10.1.6-5214329.tgz
```
![Instalar open-vm-tools](/assets/images/2017-11-02-05.png)
![Instalar open-vm-tools](/assets/images/2017-11-02-06.png)

Nos paramos dentro del directorio descomprimido y ejecutamos el instalador:

```console
root@localhost: tmp$ cd vmware-tools-distrib
root@localhost: vmware-tools-distrib$ ./vmware-install.pl
```

![Instalar open-vm-tools](/assets/images/2017-11-02-07.png)

El instalador consulta algunos parámetros del sistema y con ello
instala las herramientas

## Correr el defragmentador de disco

```console
root@localhost: $ vmware-toolbox-cmd disk shrinkonly
```

![Ejecutar open-vm-tools](/assets/images/2017-11-02-08.png)

Al cabo de un tiempo:

![Ejecutar open-vm-tools](/assets/images/2017-11-02-09.png)

Una vez finalizado, realizamos un shutdown limpio del equipo virtual.

## Comprimir la imagen con un compresor.

En este caso utilizo el compresor **7z**.


```console
roberto@desktop: vmware $ 7z a CentOS_ProyectoX
```

![Ejecutar open-vm-tools](/assets/images/2017-11-02-10.png)

El directorio de 1.6 Gbytes se almacenó en un archivo de 387 Mbytes.

