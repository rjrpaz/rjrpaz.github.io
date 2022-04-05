---
layout: post
title:  "Centralized Telephone Billing System"
date:   2014-02-21 00:00:00 -0300
categories: Centralized Telephone Billing System
---

This is a rewrite of a post from an older blog of mine:

[https://porsiserompeeldisco.blogspot.com/2014/01/sistema-centralizado-de-tarifacion.html](https://porsiserompeeldisco.blogspot.com/2014/01/sistema-centralizado-de-tarifacion.html)

For what I know, the project was not maintained by anyone else after I left so it was probably lost.

## Centralized Telephone Billing System - Cordoba government

Around 1999 I started to work for the local government (Córdoba - Argentina). I was part of the area that managed (not really, because we didn't have management access to the devices) everything related to communications and networking. This includes all things related to telephone and PBX communications.

Sadly, finding two similar PBX among all dependencies was really hard, because most of them were buy at different times and with different providers. This happened a lot not only for PBX, but also for all network-related equipment. So basically we had to deal with a kind of Noah's Ark including a large variety of different PBX.

With every PBX we should also consider separated support contracts, training effort for government personnel, different billing software, etc. All this information had to be processed separately and every management action had to be done in place (assign a new intern phone to a new employee, p.e.)

Some of the existent PBX vendors at the moment were:

- Philips (Casa de Gobierno, Ministerio de la Solidaridad).
- Ericsson (Central de Policía).
- Panasonic (Ministerio de Finanzas, Dirección General de Rentas).

As a example of the complexity of the telephone infrastructure:

- The main building used a Philips PBX (I don't remember the model but it was a *big one*).
- A dedicated PC (Windows XP) was installed to capture all the billing-related log.
- Due to the high volume of call, the system took a few hours to generate every single report.
- The performance for this system was so bad that the report generation freezed the PC pretty often so we usually lost all the billing information during that time (not to mention we had to re-launch the report generation). We usually had to do this before we leave, so we can get the required info when we arrive (if any luck) the next day.
- Having to wait a couple of days to get useful data, really impacted every analysis and we were unable to act fast.

## Centralized billing system architecture

Just a few months before start to think in a centralized system, most of the systems for the Government were put in a single location (*Supercentro*). This also implied that every dependency had network connectivity. So it was logical to start to think in a centralized solution.

Natural approach for the solution was a three-tier model like the following:

![Tarifacion centralizada](/assets/images/Tarifacion_centralizada.png)

The logger (*capturador*) upload the information to a centralized database the moment it's generated (usually when the call finishes). Then we were able to access the information using a web UI with perl-based CGI. So the information was available to anyone located in any dependency that had access to a web browser, avoiding the need to install a custom software to access the data.

The system had user-based restricted access. Every regular user of the system was allowed to see their own info, or any info related to the area they managed in case of managers. This implied to store the hierarchical relation of all dependencies and personnel.

All servers (loggers and web server/database) used Linux (Slackware and Debian).

## PBX logging

We implemented this system in the main building. We manage to develop the new system without disconnecting the previous one (just put a double RS-232 cable in read-only -RX- mode only). We didn't want to manage the PBX, just wanted to *sniff* the logging information.

For the logger we used a group of very old servers that were discarded by a Cell phone company (*CTI*) and donated to the government, as part of the technology renewal for their infrastructure. Server models were: COMPAQ DESKPRO *X466* and *XE 450*. I installed Slackware, no mouse and keyboard, network connectivity only. We were allowed to access through SSH.

A single process was running as a daemon. The process read the serial port, parses the information and uploads the billing info to the main DB server. The logger was based in *miniterm* (refer to "Linux Programmer's Guide").

The format of the billing information was different for every PBX. Even for the same brand, in some cases the format was customizable and were different in fact, which exceeded any logical behavior. The billing information was always an example of a lack of standards and the brands took advantage of that to block any integration attempt among different models and brands.

This is an example of the logging information for the main building (Philips PBX):

```console
...
* #0171101071720249375                            0474775                         13140000100431000050
* #0172208108881011         0000            000000001000048
* #0173101071720250474764     3514334394          9533                            31030000100931000011
* #0174101071720250474761     3514713779          9354                            31030000100634000038
* #0175101071720259354                            9391                            11140000000334000000
* #0176101071720259321                            0010007                         13140000000331000000
#017724394                0000            000000000000003
* #0178101071720259321                            0010009                         13140000000431000000
* #017924394                0000            000000000000004
...
```

Relevant info has a fixed position on each line. Every line as a predefined format. For example:

- Every line should start with '*' + space + '#'.
- then "01" follows.
- next two characters are a sequence number between 00 and 99. It increases by one in every line.
- next char shows if line includes *standard info* ('1') or *accounting info* ('2').
  - if line includes standard info, length of the line should be 104 chars. This line includes info related to date:
    - 2 digits for year
    - 2 digits for month
    - 2 digits for day
    - 2 digits for hour
    - 2 digits for minutes
    - 1 digit shows if call is to the PSTN ('3' in position 83)
    - 1 digit shows if call was answered ('1' in position 90)
    - It also includes info about number that originated the call.
  - if line includes accounting info, length of the line should be 61 chars and is complementary to the immediate previous standard line. This line includes info related to date:
    - length of the call in position 53
    - called number in position 8
    - number of pulse for the call in position 47.

Both lines (standard and accounting) are needed to get the whole picture about a call.

Example:

![Formato log central philips](/assets/images/Formato_log_central_philips.png)

Once all billing required info for a single call was obtained, this info was uploaded using a separated command. The logger kept a raw log with the billing info, just in case. Also, any line that didn't accomplished with expected format was logged separately.

## Uploading data to the server

First version of the uploader used a direct connection to the database. The programs used C language and Mysql API.

The size of the stored information was huge. Every PBX info was stored in separated tables because cross-PBX analysis makes no sense at that time.

Also, dependencies hierarchy was implemented in four separated tables (I assumed a max. of four levels for that). Hierarchy modification was strangely dynamic.

## Web server + CGI

CGI programs were developed using perl. First version included embedded HTML code. I eventually used templates.

Main page requesting user/password:

![login](/assets/images/TarifadorV1-login.png)

Besides billing information, user was also allowed to get reports:

![menu](/assets/images/TarifadorV1-menu.png)

First option listed last 20 records from the selected PBX. Main use for this was to show dynamic real time information from the PBX. It also suggested the high/low use for that PBX:

![last 20 records](/assets/images/TarifadorV1-Ultimos_20_registros.png)

We also managed to get a list of geographical assignment for range of telephone numbers, so that was included separately into the record. Some special numbers were manually added (*911* or *101*, p.e.)

Next three images shows reports for a day, ordered by different criteria:

- Time and date (most recent first)

![Ordenado por hora](/assets/images/TarifadorV1-Ordenado_por_hora.png)

- Call duration (longest first)

![Ordenado por duracion](/assets/images/TarifadorV1-Ordenado_por_duracion.png)

- Called number (most called first)

![Ordenado por numero mas llamado](/assets/images/TarifadorV1-Ordenado_por_numero_mas_llamado.png)

The system was able to show a distribution of calls during a day. For the graphical part I used gnuplot:

![Consumo 24hs](/assets/images/TarifadorV1-Consumo_24hs.png)

A user can create a report about an internal number or an identifier:

![filtrado por interno 1](/assets/images/TarifadorV1-filtrado_por_interno_1.png)

just select the date range and a list is showed:

![filtrado por interno 2](/assets/images/TarifadorV1-filtrado_por_interno_2.png)

The system also allowed to create a report with historical data by date and PBX:

![historico 1](/assets/images/TarifadorV1-historico_1.png)

result are showed next

![historico 2](/assets/images/TarifadorV1-historico_2.png)

Every report can be saved as pdf. For that I used *htmldoc* command:

![historico pdf](/assets/images/TarifadorV1-historico_pdf.png)

## Some final thoughts

The system was highly used from starts. This not necessarily means that contributed to minimize telephone bills, but at least was useful to provide a grainer control and lear more about calling patters.

It was also useful to integrate different brands, models and technologies in a single database, even when the source of the info was different on each case.

All involved hardware was originally discarded, so the added cost for the project was nearly zero. All involved code is open source so there were no license costs involved.

Sadly this project was abandoned when I left.
