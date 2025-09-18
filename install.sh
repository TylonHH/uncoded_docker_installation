#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

USERNAME="uncoded_test"
APP_DIR="/home/$USERNAME/uncoded-bot"
REPO_URL="https://github.com/TylonHH/uncoded_docker_installation.git"
BRANCH="dev"   # <--- hier Branch einstellen (z.B. "main" oder "dev")
ENV_FILE="$APP_DIR/.env"

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
if [ "$1" == "update" ];
