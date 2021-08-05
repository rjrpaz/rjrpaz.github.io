---
layout: post
title:  "Rebooteando TPLINK TL-R470T+ mediante script"
date:   2016-03-21 00:00:00 -0300
categories: networking scripting perl
---

Por razones que no siempre están claras, ciertos equipos de red se clavan de manera periódica. Típicamente este “cuelgue” surge a partir de un escenario de elevada carga durante mucho tiempo, o bien se presenta a partir de un uptime prolongado. Sea cual fuere el motivo, a veces es necesario recurrir al rebooteo periódico de algún equipo, previniendo un cuelgue posterior que decididamente nos arruine el tiempo de disponibilidad de nuestro servicio.

Según el equipo que debemos reiniciar, puede suceder que nuestro script deba conectarse usando http, ssh, telnet, etc. En nuestro caso, el equipo que vamos a reiniciar por script es un Tplink TL-R470T+.

Si accedemos a la interface de administración del mismo, notamos lo siguiente:

![Pantalla de login](/assets/images/Captura-de-pantalla-de-2016-03-21-132324.png)

el ingreso de usuario y contraseña no se hace por un mecanismo de autenticación http básico, sino que está integrado al desarrollo del firmware. Esto dificultaría el acceso por http.

Por otra parte, en el menú “Maintenance” -> “Admin Setup”, pestaña “Login Parameter”, aparece esto:

![Login Parameter](/assets/images/Captura-de-pantalla-de-2016-03-21-133651.png)

hay mención a un servicio de telnet. Utilizaremos este camino para reiniciar el equipo desde nuestro script.

Luego de indagar en la interface de telnet, queda claro que es posible reiniciar el equipo por este medio. La secuencia de comandos para hacerlo es la siguiente:

![Telnet session](/assets/images/Captura-de-pantalla-de-2016-03-21-135522.png)

![Telnet session](/assets/images/Captura-de-pantalla-de-2016-03-21-135956.png)

Ese es el camino que debe seguir nuestro script.
Diseñando el script

El script está hecho en perl. Para realizar sesiones interactivas (como telnet) desde perl, se puede recurrir al módulo de Expect, o bien se puede recurrir a algún módulo específico de telnet. En mi caso voy a utilizar el módulo Net::Telnet. El código del script se muestra a continuación:

```perl
    #!/usr/bin/perl
    use strict;
    use Net::Telnet;
    my $username = 'admin';
    my $password = 'admin';
    my $host = '192.168.0.1';
    my $telnet = new Net::Telnet ( Timeout=>10, Errmode=>'die');
    $telnet->open($host);
    $telnet->waitfor('/Username:$/i');
    $telnet->print($username);
    $telnet->waitfor('/Password:$/i');
    $telnet->print($password);
    $telnet->waitfor('/> $/i');
    $telnet->print('enable');
    $telnet->waitfor('/Enter password: $/i');
    $telnet->print($password);
    $telnet->waitfor('/# $/i');
    $telnet->print('sys reboot');
    $telnet->waitfor('/:/i');
    $telnet->print('Y');
    exit(0);
```

En las líneas 5-7 se definen las variables para acceder al equipo (usuario, contraseña, hostname o IP).

En la línea 9 se define el objeto que va a manejar la sesión de telnet.

En la línea 10 comienza la sesión de telnet propiamente dicha. Como primer paso, esperamos que nos devuelva la cadena “Username:”, en la línea 11. En la línea 12 ingresamos el usuario.

Como puede verse, usamos el método “waitfor” para indicar lo que esperamos que devuelva la sesión, por medio de una expresión regular. En el caso de la linea 11, indicamos que estamos esperando la cadena “Username:” al final de una línea, sin espacios luego del “:”.

Se procede de manera similar con cada uno de los comandos que debe ingresarse. Como usamos expresiones regulares, no estamos obligados a identificar la cadena completa que esperamos que nos devuelva (que de hecho, y según la ocasión, podría ser variable). En el caso de la línea 15, por ejemplo, indicamos que estamos esperando por la cadena “> ” al final de una línea, cuando lo que nos devuelve realmente es: “TP-LINK >”. Siempre que indiquemos un patrón que sea único en la línea, y que no confunda al párser de texto, no deberíamos tener inconvenientes.

Cuando desarrollemos el script, si al momento de ejecutarlo, el mismo falla indicando la línea en donde se produjo el timeout, eso típicamente nos indica que estamos esperando un patrón de texto incorrecto. Deberemos controlar entonces que el patrón esté bien definido, o deberemos simplificarlo.

El código del script está disponible aquí:

[https://github.com/rjrpaz/reboot_tlr470t](https://github.com/rjrpaz/reboot_tlr470t)

El resto implica solo agregar este script al cron, en función del momento que hayamos elegido para ejecutarlo.

