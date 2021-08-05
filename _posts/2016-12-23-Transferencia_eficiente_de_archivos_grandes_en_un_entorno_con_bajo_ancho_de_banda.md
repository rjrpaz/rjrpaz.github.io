---
layout: post
title:  "Transferencia eficiente de archivos grandes en un entorno con bajo ancho de banda"
date:   2016-12-23 00:00:00 -0300
categories: linux networking tips
---

En ocasiones debemos lidiar con algún host que tiene una conexión a Internet de “baja velocidad” (término que varía su significado según la época).

Por ejemplo, en un sitio debemos lidiar con una conexión ADSL de 3Mbps de bajada (algo así como 300Kbps de subida), compartida entre todos los integrantes de una empresa. Uno de ellos decide subir un archivo de 160Mb a su GDrive. La subida de ese archivo afecta el uso de la red durante bastante tiempo. Afecta a otros servicios, como puede ser la resolución DNS por ejemplo, y por ende termina afectando el funcionamiento generalizado de la red.

Independientemente de las acciones que podamos realizar a nivel de filtrado para evitar cierto tipo de tráfico, tenemos mecanismos para realizar copias largas de manera eficiente.

El comando rsync posee, entre sus múltiples atributos, uno que fija el límite superior de ancho de banda para una transferencia. Este atributo es: “–bwlimit”

También debemos contemplar los casos en que la transferencia se corta por algún motivo. Debido a esto, sería deseable que no debamos empezar desde cero nuevamente con la transferencia. Además, mientras menos ancho de banda destinemos a la transferencia, mayor será el tiempo de duración de la transferencia total, por lo que crecen las posibilidades de que la transferencia se corte en algún punto.

Los pasos recomendables entonces, involucran que primero se divida el archivo en “porciones” manejables. Para ello contamos con el comando “split”:

```console
roberto@desktop:~$ split -b 1m bigFile
```

En este caso partimos el archivo “bigFile” en pedazos de 1Mb. Los pedazos son nombrados por defecto con 3 letras, xaa, xab, etc. y así sucesivamente, según la cantidad de pedazos que sean.

Luego copiamos los pedazos al destino:

```console
roberto@desktop:~$ rsync -avz -e ssh --progress --bwlimit=30 x?? destHost:destDir/
```

En este caso estamos copiando todos los archivos de 3 letras, cuyo nombre comience con “x”, al host “destHost”, directorio “destDir”. Además el ancho de banda utilizado por el comando no debería superara los 30Kbps. En la práctica, y salvo algunos transitorios, esto último se respeta con suficiente precisión:

Al utilizar el comando rsync, podemos interrumpir la ejecución si es necesario, y cuando lanzamos nuevamente el comando, retomará desde el último pedazo entero que haya podido copiar.

Una vez que hemos copiado todos los pedazos, podemos unirlos en el destino, para conformar nuevamente el archivo original:

Ejecutamos en el equipo de destino:

```console
roberto@destHost:~/destDir$ cat x?? > bigFile
```

Además podemos correr una suma hash sobre el archivo en el origen y el destino, para ver si quedaron iguales:

En el origen:

```console
roberto@desktop:~$ md5sum bigFile
a04a47315647585d3243440d411aa048 bigFile
```

En el destino:

```console
roberto@destHost:~/destDir$ md5sum bigFile
a04a47315647585d3243440d411aa048 bigFile
```

Una vez que controlamos que el archivo ha sido copiado sin error, podemos eliminar los pedazos en el origen y el destino.

