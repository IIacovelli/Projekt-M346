#!/bin/bash
set -e

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
    sudo apt install git -y
else
    echo "Git bereits installiert."
fi

# DOTNET 8
if ! command -v dotnet &> /dev/null
then
    echo "Installiere .NET 8 SDK..."
    sudo apt install dotnet-sdk-8.0 -y
else
    echo ".NET bereits installiert."
fi

# AWS CLI
if ! command -v aws &> /dev/null
then
    echo "Installiere AWS CLI..."
    sudo apt install awscli -y
else
    echo "AWS CLI bereits installiert."
fi

# AWS LAMBDA TOOLS
if ! command -v dotnet-lambda &> /dev/null
then
    echo "Installiere AWS Lambda .NET Tools..."
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
    git clone <https://github.com/Marcos-dotcom1/Projekt-M346.git> Projekt-M346
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
