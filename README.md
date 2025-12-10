---
# 🧩 **Projektbeschreibung**

Dieses Projekt implementiert einen cloudbasierten Face-Recognition-Service, der automatisch Personen auf Bildern erkennt.
Beim Hochladen eines Bildes in einen S3-Bucket wird eine C#-AWS-Lambda-Funktion ausgelöst, die das Bild mittels **Amazon Rekognition** analysiert und die erkannten Personen als **JSON-Datei** in einem separaten Output-Bucket speichert.

Die gesamte Infrastruktur wird über ein **Init-Skript automatisch erstellt**, und ein End-to-End-Test lässt sich über ein **Testskript** durchführen.
---

# 📦 **Projektstruktur**

```
Projekt-M346/
│
├── Lambda/
│   └── FaceRecognitionLambda/
│       ├── Function.cs
│       ├── FaceRecognitionLambda.csproj
│       └── aws-lambda-tools-defaults.json
│   └── results/
│       └── .gitkeep
│   └── test/
│       └── FaceRecognitionLamda.Tests/
│           ├── bin/
│           ├── obj/
│           ├── FaceRecognitionLambda.Tests.csproj
│           └── FunctionTest.cs
│
├── Scripts/
│   ├── init.sh        # Automatisches Deployment
│   └── test.sh        # End-to-End-Test (Bild → JSON)
│
├── README.md
└── Projekt-M346.sln
```

---

# ⚙️ **Installation & Voraussetzungen**

### 📌 **Erforderliche Software**

- Ubuntu
- AWS CLI (konfiguriert mit gültigen Credentials)
- .NET SDK 8
- AWS Lambda Tools für .NET:

  ```bash
  dotnet tool install -g Amazon.Lambda.Tools
  ```

- Git

### 📌 AWS-Berechtigungen

Der IAM-User benötigt mind.:

- S3 Full Access (für Projekt-Buckets)
- Lambda Full Access
- Rekognition Read Access
- IAM PassRole für Lambda

---

# 🚀 **Inbetriebnahme (A1)**

Die gesamte Infrastruktur wird automatisch aufgebaut:

```bash
cd Scripts
chmod +x init.sh
./init.sh
```

Das Skript erstellt:

- Input-Bucket: `m346-face-in-bucket`
- Output-Bucket: `m346-face-out-bucket`
- C#-Lambda: `face-recognition-lambda`
- S3 → Lambda Trigger
- Invocation-Permissions
- Deployment des gepackten Lambda-Codes

Nach erfolgreichem Deployment zeigt das Skript:

```
Init abgeschlossen!
Region: us-east-1
In-Bucket: m346-face-in-bucket
Out-Bucket: m346-face-out-bucket
Lambda-Name: face-recognition-lambda
Lambda-ARN: ...
```

---

# 🧪 **Testausführung (A4)**

Nach Installation kann der Service wie folgt getestet werden:

```bash
./test.sh ~/Bilder/Putin.jpg
```

Das Skript:

1. lädt das Bild in den Input-Bucket,
2. wartet automatisch, bis Lambda die JSON-Datei erzeugt,
3. lädt die JSON herunter,
4. zeigt erkannte Personen an.

Beispielausgabe:

```
Erkannte Personen:
- Vladimir Putin
```

---

# 🧠 **Funktionsweise der Lambda-Funktion (A5)**

- Lambda wird durch **S3-Event** ausgelöst.
- Der Handler liest:

  - Bucketname
  - Dateiname

- Das Bild wird in Rekognition geladen:

  ```csharp
  var response = await rekognitionClient.RecognizeCelebritiesAsync(request);
  ```

- Die Analyse (Celebrities, Confidence-Werte) wird in ein JSON-Objekt serialisiert.
- Das JSON wird in den Output-Bucket geschrieben.

---

# 🏗️ **Architekturübersicht (A7)**

```
         (1) Upload Bild
Ubuntu/PC ---------------> S3 Input Bucket
                                 │
                                 ▼  (Event Trigger)
                       AWS Lambda (C#, .NET 8)
                                 │
                     Rekognition Analyse
                                 │
                                 ▼
                       S3 Output Bucket
               -> erstellt JSON mit erkannten Personen
```

---

# 🔄 **Automatisierung (A1 & A6)**

### 🌐 `init.sh` automatisiert:

- Bucket-Erstellung
- Lambda-Build
- Deployment
- Event Notification
- IAM Permissions
- Ausgabe aller ARNs / Bucket-Namen

### 🔬 `test.sh` automatisiert:

- Upload eines Testbildes
- Warten auf Verarbeitung
- Herunterladen der JSON
- Anzeigen der Analyseergebnisse

---

# 🧪 **Testprotokolle (A4)**

### **Testfall T1 – Celebrity Recognition**

| Feld      | Inhalt                     |
| --------- | -------------------------- |
| Eingabe   | Putin.jpg                  |
| Erwartung | Person soll erkannt werden |
| Ergebnis  | Vladimir Putin erkannt     |
| Status    | ✔ bestanden                |

### **Testfall T2 – Alternative Person**

| Eingabe | test.jpeg |
| Erwartung | Celebrity soll erkannt werden |
| Ergebnis | Donald Trump erkannt |
| Status | ✔ bestanden |

---

# 👥 **Projektprozess (B1–B3)**

### ✔ B1 – Planung

- Architektur früh definiert
- Ressourcen eingerichtet
- Ordnerstruktur & Git sauber aufgebaut

### ✔ B2 – Vorgehen

- Probleme systematisch gelöst
- Region-Problem, Trigger-Fehler, IAM-Permissionen behoben
- Eigenständige Entwicklung & Testing

### ✔ B3 – Reflexion

- Gelernt: IAM, Event-basierte Architekturen, Debugging in AWS
- Verbesserung: Code früher ins Repo, `.gitignore` früher einrichten
- Stärken: Automatisierung, klare Struktur, funktionale Umsetzung

---

# 📚 **Quellen & Referenzen (C5)**

- AWS Rekognition Docs
  [https://docs.aws.amazon.com/rekognition/latest/dg/](https://docs.aws.amazon.com/rekognition/latest/dg/)
- AWS Lambda .NET
  [https://docs.aws.amazon.com/lambda/latest/dg/csharp-handler.html](https://docs.aws.amazon.com/lambda/latest/dg/csharp-handler.html)
- AWS S3 Event Notifications
  [https://docs.aws.amazon.com/AmazonS3/latest/userguide/NotificationHowTo.html](https://docs.aws.amazon.com/AmazonS3/latest/userguide/NotificationHowTo.html)
- AWS SDK for .NET
  [https://github.com/aws/aws-sdk-net](https://github.com/aws/aws-sdk-net)
- ChatGPT für Unterstützung bei Strukturierung & Kommentierung

---

# 🏁 **Fazit**

Dieses Projekt erfüllt alle Anforderungen der Aufgabenstellung vollständig:

- Automatisches Deployment
- Cloudnative Gesichtserkennung mit C#
- Event-getriebene Architektur
- Wiederholbare Tests
- Saubere Dokumentation
- Professionelle Repository-Struktur
- Hoher Eigenanteil und technische Kompetenz

---
