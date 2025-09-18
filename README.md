# uncoded-trading-bot Setup

Dieses Repository richtet den [uncoded-trading-bot](https://t.me/unCoded_bot?start=ref_1203406052) auf einem Ubuntu-Server ein.

## Voraussetzungen

- Ubuntu (empfohlen)
- Root-Zugang (z. B. via SSH)

## Installation

Führe auf deinem Server als root aus:

```bash
wget https://raw.githubusercontent.com/deinname/uncoded-bot/main/install.sh
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

Vor einem Update **immer zuerst den Bot in Telegram beenden**. (TOS = flase)

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
