#!/bin/bash
set -e

# --- SAFE APT LOCK HANDLER ---
wait_for_apt() {
    echo "Prüfe APT-Locks ..."

    # Wait until lock is free (max 60s)
    TIMEOUT=60
    while fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        if [ $TIMEOUT -le 0 ]; then
            echo "APT-Lock hängt fest. Beende blockierende Prozesse..."
            
            # Kill unattended-upgrades safely
            sudo systemctl stop unattended-upgrades || true
            sudo killall unattended-upgrade || true
            
            sudo rm -f /var/lib/dpkg/lock-frontend
            sudo rm -f /var/cache/apt/archives/lock
            
            sudo dpkg --configure -a || true
            break
        fi

        echo "APT ist gesperrt. Warte... ($TIMEOUT s)"
        sleep 2
        TIMEOUT=$((TIMEOUT-2))
    done

    echo "APT-Lock frei. Weiter geht's."
}

echo "Starte vollständige automatische Installation ..."

#############################################
# 1) SYSTEM UPDATE
#############################################
echo "Aktualisiere Ubuntu ..."
sudo apt update && sudo apt upgrade -y


#############################################
# 2) INSTALL REQUIRED SOFTWARE
#############################################
echo "Installiere benötigte Pakete ..."

# GIT
if ! command -v git &> /dev/null
then
    echo "Installiere Git..."
    wait_for_apt
    sudo apt install git -y
else
    echo "Git bereits installiert."
fi

# DOTNET 8
if ! command -v dotnet &> /dev/null
then
    echo "Installiere .NET 8 SDK..."
    wait_for_apt
    sudo apt install dotnet-sdk-8.0 -y
else
    echo ".NET bereits installiert."
fi

# AWS CLI
if ! command -v aws &> /dev/null
then
    echo "Installiere AWS CLI..."
    wait_for_apt
    sudo apt install awscli -y
else
    echo "AWS CLI bereits installiert."
fi

# AWS LAMBDA TOOLS
if ! command -v dotnet-lambda &> /dev/null
then
    echo "Installiere AWS Lambda .NET Tools..."
    wait_for_apt
    dotnet tool install -g Amazon.Lambda.Tools
else
    echo "AWS Lambda Tools bereits installiert."
fi

#############################################
# 3) CHECK AWS CONFIG
#############################################
echo "Prüfe AWS CLI Konfiguration ..."
if ! aws sts get-caller-identity &> /dev/null
then
    echo "AWS ist nicht konfiguriert! Bitte jetzt einrichten:"
    aws configure
else
    echo "AWS CLI korrekt konfiguriert."
fi


#############################################
# 4) DOWNLOAD PROJECT (OPTIONAL)
#############################################
PROJECT_FOLDER="Projekt-M346"

if [ ! -d "$PROJECT_FOLDER" ]; then
    echo "Klone Repository..."
    git clone https://github.com/Marcos-dotcom1/Projekt-M346.git Projekt-M346
else
    echo "Projektordner existiert bereits."
fi


#############################################
# 5) RUN INIT.SH
#############################################
echo "Führe Infrastructure Deployment aus ..."
cd Projekt-M346/Scripts

chmod +x init.sh
./init.sh


#############################################
# 6) ASK FOR TEST IMAGE
#############################################
echo ""
echo "Wähle ein lokales Testbild für den End-to-End-Test:"
echo "Beispiel:  /home/user/Pictures/putin.jpg"
read -p "Pfad zum Bild eingeben: " TESTIMAGE

if [ ! -f "$TESTIMAGE" ]; then
    echo " Fehler: Datei nicht gefunden."
    exit 1
fi

#############################################
# 7) RUN TEST.SH
#############################################
echo "Starte End-to-End Test ..."

chmod +x test.sh
./test.sh "$TESTIMAGE"


#############################################
# DONE
#############################################
echo ""
echo "Alles abgeschlossen!"
echo "Der Face-Recognition-Service läuft vollständig."
echo ""
