#!/bin/bash
set -e

USERNAME="uncoded"
APP_DIR="/home/$USERNAME/uncoded-bot"
REPO_URL="https://github.com/TylonHH/uncoded_docker_installation.git"
ENV_FILE="$APP_DIR/.env"

# Prüfen ob root
if [ "$(id -u)" -ne 0 ]; then
  echo "Bitte als root ausführen (sudo bash install.sh [update])"
  exit 1
fi

# Funktion: Update
update_bot() {
  echo "=== Bot-Update starten ==="
  echo "WICHTIG: Stelle sicher, dass der Bot in Telegram mit /tos false beendet wurde!"
  echo "Drücke [Enter], um fortzufahren..."
  read

  cd $APP_DIR
  echo "--- Repository aktualisieren ---"
  sudo -u $USERNAME git pull

  echo "--- Neues Image ziehen ---"
  sudo -u $USERNAME docker compose pull

  echo "--- Container neu starten ---"
  sudo -u $USERNAME docker compose up -d

  echo "=== Update abgeschlossen ==="
  sudo -u $USERNAME docker compose ps
  exit 0
}

# Prüfen ob Update-Flag
if [ "$1" == "update" ]; then
  update_bot
fi

# --- Installation ---
echo "=== Neuen Benutzer $USERNAME anlegen ==="
if id "$USERNAME" &>/dev/null; then
  echo "Benutzer $USERNAME existiert bereits, überspringe..."
else
  adduser --disabled-password --gecos "" $USERNAME
  usermod -aG sudo $USERNAME
fi

echo "=== Pakete installieren ==="
apt-get update
apt-get install -y git docker.io docker-compose

echo "=== Benutzer $USERNAME zur docker-Gruppe hinzufügen ==="
usermod -aG docker $USERNAME

echo "=== Repository einrichten ==="
sudo -u $USERNAME mkdir -p $APP_DIR
if [ ! -d "$APP_DIR/.git" ]; then
  sudo -u $USERNAME git clone $REPO_URL $APP_DIR
else
  cd $APP_DIR && sudo -u $USERNAME git pull
fi

cd $APP_DIR

echo "=== ENV-Datei konfigurieren ==="
if [ -f "$ENV_FILE" ]; then
  echo ".env existiert schon, überschreibe..."
  rm "$ENV_FILE"
fi

# Funktion für Eingabe mit Wiederholung
ask_value() {
  local var_name=$1
  local prompt=$2
  local value=""

  while [ -z "$value" ]; do
    read -p "$prompt: " value
    if [ -z "$value" ]; then
      echo "FEHLER: $var_name darf nicht leer sein!"
    fi
  done

  eval "$var_name=\"$value\""
}

ask_value API_KEY "Binance API_KEY"
ask_value API_SECRET "Binance API_SECRET"
ask_value TELEGRAM_GROUP_ID "Telegram Group ID"
ask_value TELEGRAM_OWNER_ID "Telegram Owner ID"
ask_value TELEGRAM_BOT_TOKEN "Telegram Bot Token"

cat <<EOF > "$ENV_FILE"
# --- Automatisch erzeugt ---
API_KEY=$API_KEY
API_SECRET=$API_SECRET
TELEGRAM_GROUP_ID=$TELEGRAM_GROUP_ID
TELEGRAM_OWNER_ID=$TELEGRAM_OWNER_ID
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
EOF

chown $USERNAME:$USERNAME "$ENV_FILE"

echo "=== Container starten ==="
sudo -u $USERNAME docker compose up -d

echo "=== Installation abgeschlossen ==="
sudo -u $USERNAME docker compose ps
