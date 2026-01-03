# Automator PowerShell Skript Beispiel
# Die Dateipfade werden als Argumente übergeben und landen in $args

$logDatei = "~/Desktop/PS_Log.txt"

# Leitet die Ausgabe an die Log-Datei
"--- Start der Ausführung $(Get-Date) ---" | Out-File -FilePath $logDatei -Append

# Überprüfen, ob Argumente übergeben wurden
if ($args.Length -gt 0) {
    "Anzahl der empfangenen Dokumente: $($args.Length)" | Out-File -FilePath $logDatei -Append
    
    # Durchlaufen Sie jedes übergebene Dokument
    foreach ($dokumentPfad in $args) {
        "Verarbeite Dokument: $dokumentPfad" | Out-File -FilePath $logDatei -Append
        
        # Fügen Sie hier Ihre spezifische Logik ein
        # Beispiel: Ausgabe des Dateinamens und der Größe
        try {
            $dateiInfo = Get-Item -Path $dokumentPfad
            "Name: $($dateiInfo.Name), Größe: $($dateiInfo.Length) Bytes" | Out-File -FilePath $logDatei -Append
        } catch {
            "Fehler beim Zugriff auf ${dokumentPfad}: $_" | Out-File -FilePath $logDatei -Append
        }
    }
} else {
    "Keine Dokumente empfangen." | Out-File -FilePath $logDatei -Append
}

"Skript beendet." | Out-File -FilePath $logDatei -Append