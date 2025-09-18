#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

USERNAME="uncoded"
APP_DIR="/home/$USERNAME/uncoded-bot"
REPO_URL="https://github.com/TylonHH/uncoded_docker_installation.git"
BRANCH="main"   # <--- hier Branch einstellen (z.B. "main" oder "dev")
ENV_USER_FILE="$APP_DIR/.env.user"
ENV_FIXED_FILE="$APP_DIR/.env.fixed"

# Prüfen ob root
if [ "$(id -u)" -ne 0 ]; then
  echo "Bitte als root ausführen (sudo bash install.sh [update])"
  exit 1
fi

# Funktion: Update
update_bot() {
  echo "=== Bot-Update starten ==="
  echo "WICHTIG: Stelle sicher, dass der Bot in Telegram mit TOS = false beendet wurde!"
  echo "Drücke [Enter], um fortzufahren..."
  read

  cd $APP_DIR
  echo "--- Repository aktualisieren ---"
  sudo -u $USERNAME git fetch origin
  sudo -u $USERNAME git checkout $BRANCH
  sudo -u $USERNAME git pull origin $BRANCH

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

echo "=== Docker prüfen ==="
if command -v docker &>/dev/null && docker compose version &>/dev/null; then
  echo "Docker CE + Compose V2 sind bereits installiert, überspringe Neuinstallation."
else
  echo "=== Entferne alte Docker-Pakete ==="
  apt-get purge -y docker docker-engine docker.io docker-compose containerd runc || true
  apt-get autoremove -y
  apt-get clean
  apt-get update

  echo "=== Setze Pinning, um Ubuntu-Pakete zu blockieren ==="
  mkdir -p /etc/apt/preferences.d
  cat <<EOF > /etc/apt/preferences.d/docker.pref
Package: docker.io
Pin: release *
Pin-Priority: -1

Package: docker-compose
Pin: release *
Pin-Priority: -1

Package: containerd
Pin: release *
Pin-Priority: -1

Package: runc
Pin: release *
Pin-Priority: -1
EOF

  echo "=== Voraussetzungen installieren ==="
  apt-get install -y ca-certificates curl gnupg lsb-release git

  echo "=== Docker Repository hinzufügen ==="
  mkdir -p /etc/apt/keyrings
  if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  fi
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

  echo "=== Docker & Compose V2 installieren ==="
  apt-get update
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
fi

echo "=== Benutzer $USERNAME zur docker-Gruppe hinzufügen ==="
usermod -aG docker $USERNAME

echo "=== Repository einrichten ==="
sudo -u $USERNAME mkdir -p $APP_DIR
if [ ! -d "$APP_DIR/.git" ]; then
  sudo -u $USERNAME git clone -b $BRANCH --single-branch $REPO_URL $APP_DIR
else
  cd $APP_DIR
  sudo -u $USERNAME git fetch origin
  sudo -u $USERNAME git checkout $BRANCH
  sudo -u $USERNAME git pull origin $BRANCH
fi

cd $APP_DIR

echo "=== ENV-Dateien konfigurieren ==="
# Feste Datei bleibt immer aus Repo
if [ ! -f "$ENV_FIXED_FILE" ]; then
  echo "WARNUNG: $ENV_FIXED_FILE fehlt! Bitte aus dem Repo bereitstellen."
fi

# User-Datei immer neu erstellen
if [ -f "$ENV_USER_FILE" ]; then
  echo ".env.user existiert schon, überschreibe..."
  rm "$ENV_USER_FILE"
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

cat <<EOF > "$ENV_USER_FILE"
# --- Automatisch erzeugt ---
API_KEY=$API_KEY
API_SECRET=$API_SECRET
TELEGRAM_GROUP_ID=$TELEGRAM_GROUP_ID
TELEGRAM_OWNER_ID=$TELEGRAM_OWNER_ID
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
EOF

chown $USERNAME:$USERNAME "$ENV_USER_FILE"

echo "=== Container starten ==="
sudo -u $USERNAME docker compose up -d

echo "=== Installation abgeschlossen ==="
sudo -u $USERNAME docker compose ps

echo "=== Prüfe Docker Compose Version ==="
docker compose version
