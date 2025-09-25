# uncoded-trading-bot Setup

Dieses Repository richtet den [uncoded-trading-bot](https://t.me/unCoded_bot?start=ref_1203406052)* auf einem Ubuntu-Server ein.

## Voraussetzungen

- Ubuntu (empfohlen) zum Beispiel bei [netcup](https://www.netcup.com/de/?ref=280996)*
- Root-Zugang (z. B. via SSH)
- [Binance Account](https://accounts.binance.com/register?ref=15618672)*

## Installation

Führe auf deinem Server als root aus:

```
wget -O install.sh https://raw.githubusercontent.com/TylonHH/uncoded_docker_installation/refs/heads/main/install.sh
sudo bash install.sh
````

Das Skript fragt nach folgenden Werten:

* Binance API\_KEY
* Binance API\_SECRET
* Telegram Group ID
* Telegram Owner ID
* Telegram Bot Token

Danach werden:

* ein Benutzer `uncoded` angelegt
* Docker und Docker Compose installiert
* das Repository geklont
* die Container gestartet

## Update

Vor einem Update **immer zuerst den Bot in Telegram beenden**. (TOS = false)

Dann:

```bash
cd /home/uncoded/uncoded-bot
sudo bash install.sh update
```

Das Skript macht automatisch:

* `git pull`
* `docker compose pull`
* `docker compose up -d`

## Verwaltung

* vorher in den Ordner wechseln

  ```bash
  cd uncoded-bot
  ```


* Containerstatus:

  ```bash
  docker compose ps
  ```

* Logs:

  ```bash
  docker compose logs -f
  ```

* Stoppen:

  ```bash
  docker compose down
  ```

* Neu starten:

  ```bash
  docker compose up -d
  ```

## Starte den Bot

Anschließend den Bot hier direkt in Telegram starten:
👉 [uncoded-trading-bot](https://t.me/unCoded_bot?start=ref_1203406052)

## Zugriff auf die postgres Datenbank

port vorher freiegen für eigene IP
sudo ufw allow from DEINE_IP_ADRESSE to any port 5432 proto tcp
http://www.dnstools.ch/wie-ist-meine-ip.html
https://www.pgadmin.org/download/ aber jedes andere Tool für den exterenn Zugriff sollte ähnlich sein.
Zeile mit Port auskommentieren in der yml
docker up etc


## Unterstützung

Du möchtest dich für diese Anleitung bedanken?

<a href="https://www.buymeacoffee.com/WarsoWerk" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" style="height: 60px !important;width: 217px !important;" ></a>

<sup>Die mit Sternchen (*) gekennzeichneten Links sind sogenannte Affiliate-Links</sup>
