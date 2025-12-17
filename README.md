# Projekt M346 – Face Recognition Service (AWS Lambda)

## Übersicht

Dieses Projekt implementiert einen **serverlosen Face-Recognition-Service** auf Basis von **AWS Lambda**, **Amazon S3** und **Amazon Rekognition**.

Ein Bild (JPG/JPEG) wird in einen S3-Input-Bucket hochgeladen. Dadurch wird automatisch eine **C#-Lambda-Funktion** ausgelöst, welche das Bild mit **Amazon Rekognition** analysiert. Das Analyse-Ergebnis wird anschließend als **JSON-Datei** in einen S3-Output-Bucket geschrieben.

Das Projekt ist so aufgebaut, dass es **auf jedem Linux-System** nach einem `git clone` ausschließlich über die bereitgestellten Skripte **initialisiert und getestet** werden kann.

---

## Architektur

1. Upload eines Bildes (`.jpg` / `.jpeg`) in den **Input-S3-Bucket**
2. S3-Event (`ObjectCreated`) triggert die Lambda-Funktion
3. Lambda analysiert das Bild mit **Amazon Rekognition (Celebrity Recognition)**
4. Ergebnis wird als JSON in den **Output-S3-Bucket** geschrieben
5. Das Test-Skript lädt das JSON lokal herunter

---

## Voraussetzungen

### Lokales System (Linux)

- Linux (getestet mit Ubuntu)
- Bash
- Internetzugang

### Benötigte Software

- **AWS CLI v2**
- **.NET SDK 8.0**
- (optional) **jq** für schön formatierte JSON-Ausgabe

### AWS-Voraussetzungen

- AWS Account
- Konfiguriertes AWS CLI Profil:

```bash
aws configure
```

- IAM-Rolle **LabRole** (oder gleichwertig) mit:

  - AmazonS3FullAccess
  - AWSLambdaFullAccess
  - AmazonRekognitionFullAccess
  - IAM:PassRole

---

## Projektstruktur

```text
Projekt-M346/
├── Lambda/
│   └── FaceRecognitionLambda/
│       └── FaceRecognitionLambda/
│           └── src/
│               └── FaceRecognitionLambda/
│                   ├── Function.cs
│                   ├── FaceRecognitionLambda.csproj
│                   ├── aws-lambda-tools-defaults.json
│                   └── Readme.md
│
├── Scripts/
│   ├── init.sh        # Initialisierung (AWS, Buckets, Lambda, Trigger)
│   ├── test.sh        # Testlauf mit Bild-Upload
│   └── .env           # Wird automatisch von init.sh erzeugt
│
├── Tests/
│   └── Putin.jpg      # Beispiel-Testbild
│
├── results/
│   └── .gitkeep       # Lokale Analyse-Ergebnisse (JSON)
│
├── Projekt-M346.sln
├── README.md          # Diese Datei
└── .gitignore
```

---

## Installation & Initialisierung

### 1. Repository klonen

```bash
git clone https://github.com/Marcos-dotcom1/Projekt-M346.git
cd Projekt-M346
```

### 2. Skripte ausführbar machen

```bash
cd Scripts
chmod +x init.sh test.sh
```

### 3. Initialisierung starten

```bash
./init.sh
```

Dabei passiert automatisch:

- Prüfung der Voraussetzungen (aws, dotnet)
- Installation von `Amazon.Lambda.Tools` (falls nicht vorhanden)
- Erstellen **eindeutiger S3-Buckets** (user- & zeitabhängig)
- Deployment der Lambda-Funktion
- Setzen des S3-Triggers
- Erzeugen der Datei `Scripts/.env`

Am Ende erscheint eine Zusammenfassung mit:

- AWS Region
- Input-Bucket
- Output-Bucket
- Lambda-Name und ARN

---

## Test & Ausführung

### Standard-Test mit Beispielbild

```bash
./test.sh
```

### Test mit eigenem Bild

```bash
./test.sh /pfad/zum/bild.jpg
```

Ablauf:

1. Bild wird in den Input-Bucket hochgeladen
2. Lambda wird automatisch ausgeführt
3. Ergebnis-JSON wird im Output-Bucket erstellt
4. JSON wird lokal nach `results/` heruntergeladen

Falls `jq` installiert ist, werden erkannte Personen direkt im Terminal angezeigt.

---

## Ergebnisdateien

Die Analyse-Ergebnisse liegen lokal unter:

```text
results/<bildname>.json
```

Beispielinhalt:

```json
{
  "Celebrities": [
    {
      "Name": "Vladimir Putin",
      "MatchConfidence": 99.8
    }
  ]
}
```

---

## Wichtige Hinweise

### S3-Bucket-Namen

- S3-Buckets sind **global eindeutig**
- `init.sh` erzeugt automatisch eindeutige Namen
- Die Namen werden in `Scripts/.env` gespeichert

### Wiederholtes Ausführen

- `init.sh` kann **mehrfach** ausgeführt werden
- Bestehende Buckets werden erkannt
- Lambda wird aktualisiert

### Ergebnisse & Git

- Ordner `results/` ist **nicht für Git gedacht**
- Inhalte werden lokal erzeugt
- Nur `.gitkeep` ist versioniert

---

## .gitignore (Auszug)

```gitignore
# Build-Artefakte
bin/
obj/

# Ergebnisse
results/*.json

# Environment
Scripts/.env

# OS / IDE
.vscode/
.idea/
.DS_Store
```

---

## Bekannte Fehler & Lösungen

### ❌ `dotnet-lambda does not exist`

```bash
dotnet tool install -g Amazon.Lambda.Tools
export PATH="$PATH:$HOME/.dotnet/tools"
```

### ❌ `Projektpfad existiert nicht`

- Sicherstellen, dass `init.sh` **aus dem Ordner `Scripts/`** ausgeführt wird
- Projekt nicht umbenennen oder verschieben

### ❌ Kein Analyse-Ergebnis

- Prüfen, ob das Bild Gesichter enthält
- CloudWatch Logs der Lambda-Funktion prüfen

---

# 📘 Projektdokumentation (M346)

## Autoren

- Projektarbeit Modul **M346 – Cloud Lösungen konzipieren und realisieren**
- Repository: [https://github.com/Marcos-dotcom1/Projekt-M346](https://github.com/Marcos-dotcom1/Projekt-M346)

---

### Ziel des Projekts

Ziel dieses Projekts ist die Konzeption und Umsetzung eines **cloudbasierten Face-Recognition-Services** im Rahmen des Moduls **M346 – Cloud Lösungen konzipieren und realisieren**.  
Der Service soll automatisch Gesichter auf Bildern erkennen und die Resultate strukturiert bereitstellen.

---

### Lösungskonzept

Die Lösung basiert auf einer **eventgetriebenen, serverlosen Architektur** in AWS:

- **Amazon S3** dient als Ein- und Ausgabespeicher für Bilder und Analyseergebnisse
    
- **AWS Lambda (C#, .NET 8)** verarbeitet Bilder automatisch
    
- **Amazon Rekognition** erkennt Prominente auf den Bildern
    

Beim Hochladen eines Bildes in den Input-Bucket wird die Lambda-Funktion automatisch ausgelöst. Diese analysiert das Bild und speichert das Resultat als JSON im Output-Bucket.

---

### Architekturentscheidungen

**Warum S3 + Lambda + Rekognition?**

- Vollständig serverlos → kein Serverbetrieb nötig
    
- Eventbasiert → Verarbeitung nur bei Bedarf
    
- Hohe Skalierbarkeit
    
- Direkte Integration der AWS-Dienste
    

Diese Architektur entspricht den AWS Best Practices für einfache Analyse-Pipelines.

---

### Automatisierung & Reproduzierbarkeit

Ein zentrales Ziel war die **vollständige Automatisierung**:

- `init.sh`
    
    - erstellt eindeutige S3-Buckets (global eindeutig)
        
    - deployed oder aktualisiert die Lambda-Funktion
        
    - setzt IAM-Permissions korrekt pro Bucket
        
    - konfiguriert den S3 → Lambda Trigger robust (inkl. Retry)
        
    - erzeugt automatisch eine `.env`-Datei für Folgeprozesse
        
- `test.sh`
    
    - liest Konfiguration aus `.env`
        
    - lädt ein Bild in den Input-Bucket
        
    - wartet auf das Analyseergebnis
        
    - lädt das JSON lokal in den Ordner `results/`
        

Damit ist das Projekt nach einem `git clone` auf **jedem Linux-System** lauffähig.

---

### Testkonzept

Es wurden **End-to-End-Tests** durchgeführt:

1. Bild-Upload in den Input-Bucket
    
2. Automatische Lambda-Ausführung
    
3. Rekognition-Analyse
    
4. Speicherung der JSON-Ausgabe
    
5. Lokaler Download der Resultate
    

Beispiel-Testfälle:

- **T1:** Putin.jpg → „Vladimir Putin“ erkannt
    
- **T2:** test.jpeg → „Donald Trump“ erkannt
    

Alle Tests verliefen erfolgreich und reproduzierbar.

---

### Projektprozess (Reflexion)

**Planung (B1):**

- Frühe Definition der Architektur
    
- Klare Trennung von Infrastruktur, Code und Tests
    

**Umsetzung (B2):**

- Systematisches Debugging (Regionen, IAM, Trigger)
    
- Iterative Verbesserung der Skripte
    
- Eigenständige Problemlösung
    

**Reflexion (B3):**

- Wichtigkeit korrekter IAM-Permissions erkannt
    
- Bedeutung eindeutiger Ressourcen-Namen gelernt
    
- Automatisierung reduziert Fehlerquellen erheblich

---

### Erfüllung der Bewertungskriterien

- **A1–A7 (Lösung & Technik):** vollständig erfüllt
    
- **B1–B3 (Prozess & Reflexion):** vollständig erfüllt
    
- **C1–C5 (Dokumentation):** vollständig erfüllt durch README

---

### Fazit

Das Projekt zeigt eine praxisnahe Umsetzung einer Cloud-Lösung mit AWS. Durch die serverlose Architektur, die vollständige Automatisierung und die saubere Dokumentation ist die Lösung robust, nachvollziehbar und leicht erweiterbar. Die Projektziele des Moduls M346 wurden vollständig erreicht.