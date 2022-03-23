---
layout: post
title:  "Monitoring Infrastructure for local government using Big Brother"
date:   2014-02-20 00:00:00 -0300
categories: Big Brother Monitoreo MRTG perl SNMP
---

This is a rewrite of a post from an older blog of mine:

[https://porsiserompeeldisco.blogspot.com/2014/02/sistema-de-moniteo-de-red-gobierno-de.html](https://porsiserompeeldisco.blogspot.com/2014/02/sistema-de-moniteo-de-red-gobierno-de.html)

Most of this information is outdated and is mostly kept just for historical purposes only.

## Infrastructure monitoring system

Around 1999 I started to work for the local goverment (Córdoba - Argentina). I was part of the area that managed (not really, because we didn't have management access to the devices) everything related to communication and networking. At that time, every dependency had a couple of WAN links to the main computer area (*Supercentro*). This links were provided by at least two different providers for redundancy.

Monitoring wasn't implemented, at least not a comprehensive one that included different providers and areas (a few providers implemented a ad-hoc station including HP OpenView but access to this information was not widely available). Every time an incident occurred, the usual approach was blame someone else until the issue was solved by itself. In the meantime, incidents happened all the time due to an endless list of providers, devices manufactures, technologies involved, etc. A simple sniffer showed that the network was more like a network lab or a "zoo".

I implemented a monitoring system using *Big Brother* and *MRTG* (at that time Nagios was not known).

## Implementing Big Brother

At that time I had little experience using SNMP and a lot more with open source tools. I knew about Big Brother thanks to a couple of articles from The Linux Journal. This tool was mostly based in C and shell scripts, so it seemed possible to add enhancements.

First step was to monitoring WAN links to every area. Due to the high number of links (like one hundred dependencies), I had to use fping instead of ping, because the monitoring cycle was extremely slow when some link were down. Just as an example:

- Most of the dependencies in the city of Córdoba owned two links:
    1. Digital link 512 KBPS (Telecom)
    1. Wireless link 1 MBPS (Techtel)
- Dependencies from other cities used a second link from Impsat (Techtel usually had no service in those cities). Impsat provided satellites-based communication links.
- Internet access was covered by Telecom and Telefónica.

To simplify network management for this mess, a single provider (Techtel) was in charge of configuring the routers were both links arrived on every dependency. The idea from the customer (ourselves) was trying to use both links at full capacity if possible, because they were too expensive. However, Techtel never managed to get this to properly work. They implemented "HRSP" as load balancer protocol which changed active link every few seconds, as a sort of "crazy dance" that never worked fine. Ironically, Techtel included an item in the bill called "load balancing", so they were charging the state for this non-functional mess.

The actual behavior of the network was to use Techtel as main link between dependencies and Telecom was only involved when main link failed. This failures were very common:

- Wireless links used a relatively low frequency and there was a lot of interferences. This was fixed a few years later when frequency raise from 2.4 Ghz to 5 Ghz.
- Higher latency, so the digital link was perceived as better performance, even with half size.

Some dependencies had a lot of traffic (Rentas, Catastro) but some others don't (Teatro Real, Museo Carafa) because they included maybe a single computer. Each one had two links, doesn't matter which one. This is a clear waste of money in the latest cases.

Anyway ... this tool was useful to exclude/confirm WAN links for being the source of incidents and help narrowed down the possible candidates on every problem.

## Implementing MRTG

We requested each provider to enable read only SNMP access to the devices. This was initially rejected by some of the because they considered this was a security risk. In some cases we even had to do a recovery of the Cisco router to insert the required SNMP configuration. In some other cases, the provider helped to the process.

Once the service was enabled I implemented MRTG. I also modified both codes to link both tools each other. Enable SNMP traps showed us that wireless link went down a lot more that we knew at that time (off course, monitoring period from big brother was just a sampling of this).

## User interface

Big Brother showed group of links according to the dependency or the place:

![BB main page](/assets/images/bb-pagina_principal.png)

Each group allow to access a specific list of links. "Conexiones Telecom" p.e. showed the list of links for Telecom:

![BB telecom](/assets/images/bb-enlaces_telecom.png)

or Techtel:

![BB techtel](/assets/images/bb-enlaces_techtel.png)

From every listed link we can access to specific information for that link:

![BB techtel Cordoba Ciencia](/assets/images/bb-cordoba_ciencia_techtel.png)

I added a "HISTORY" button including info from the last 36 hours:

![BB history](/assets/images/bb-historico.png)

this image was created using perl and GD library. This clearly showed instability on some links (we internally named those as "zebras" due to this graphic).

I also included web links to pages for the rest of the providers in the same dependency. The button "Gráfico Comparativo" compared graphics between providers:

![BB compare graphics](/assets/images/bb-grafico_comparativo.png)

I added a web link from the list of links ("gráfico de carga") that showed related MRTG entry:

![MRTG Cordoba Ciencia](/assets/images/mrtg-cordoba_ciencia_techtel-2.png)

![MRTG Cordoba Ciencia](/assets/images/mrtg-cordoba_ciencia_techtel.png)

latest graphic is an example of link usage in a dependency.

There were some additional web links at the end of every provider list:

![BB agregados en enlaces Techtel](/assets/images/bb-enlaces_techtel_agregados.png)

"Registro de Reclamos" was used by help desk team and allowed to store related information abount a support ticket opened to the provider. Each member from the team was able to check status about the ticket to do a follow up of the issue. That screen looked like this:

![BB lista reclamos telecom](/assets/images/bb-reclamos_telecom_lista.png)

Once a link is selected from the list, it looked like this:

![BB carga reclamos telecom](/assets/images/bb-reclamos_telecom_carga.png)

That form allowed to store some useful info like the following:

- phone number
- technical contact
- reference number for that line according to the provider inventory

All this information was stored separately in a GDBM-type database.

The option "Enlaces Inestables" brings to the list of more unstable links for every provider (according to big brother):

![BB enlaces inestables](/assets/images/bb-enlaces_inestables-1.png)

![BB enlaces inestables](/assets/images/bb-enlaces_inestables-2.png)

These last two entries were added to big brother. Graphic was created using perl and GD library.

## Some final thoughts

Big brother was easily adopted by non so technical members of the area (help desk is a good example). With time they learned how to use it and arrive to right conclusion according to what they see in the monitoring tool.

Big Brother was eventually used to monitor windows servers resources (services, logs, disk space, etc).
