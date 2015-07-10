# pyload-runscript
Automatically exported from code.google.com/p/pyload-runscript

DATENSICHERUNG #### NOTIZ AN MICH: BEARBEITEN (URLs ANPASSEN)



Dieser "Script-Pack" ist als "Custom Userscript" für pyLoad gedacht. Die Scripte entpacken heruntergeladene RAR-Archive, löschen diese nach erfolgreichem entpacken und bereinigen die Dateinamen. Zudem werden überflüssige Dateien wie Textfiles, NFO-, SFV-Dateien, Samples, Subs und URL-Verweise gelöscht. 

Sind Archive passwortgeschützt, so sucht das Unrar-Script in der Passwortdatei "passwoerter" nach einem hinterlegten PW. 

Die aus dem Dateinamen zu entfernenden Teile/Bezeichnungen sind frei editierbar, dazu muss lediglich die Datei "DELNAME" bearbeitet, bzw. um die zu löschenden Bezeichnungen erweitert werden (eine Ersetzungsvariable pro Zeile). "DELNAME" enthält schon viele Ersetzungsvariablen, wie Scene- oder Release-Tags. Die Dateinamen können optional komplett in Kleinbuchstaben oder der erste Buchstabe jedes vorkommenden Wortes in Großbuchstaben ausgegeben werden (siehe Beispiel weiter unten). 

Nach dem Umbenennen werden die Dateien (beispielsweise) ins Medienverzeichnis verschoben. Serien werden in den entsprechenden Serienordner des frei definierbare Serienverzeichnis verschoben, dazu muss nur die Datei "SERIEN" bearbeitet werden. Das Script prüft die heruntergeladenen Dateien auf in dem File ("SERIEN") eingetragene (Serien-) Namen und verschiebt bei einem Treffer den Download in dieses Verzeichnis; es reicht eine Eintragung, ist das Verzeichnis nicht angelegt, erledigt dies das Script automatisch. 


Beispiele: 

Wird beispielsweise nachfolgende Serie als RAR-Archiv heruntergeladen, so entpackt das Script die Datei und benennt sie aus meiner persönlichen Sicht sinnvoll um 

Original-Dateiname odd-job-jack.s01e02.German.AC3D.DL.1080p.BluRay.x264-LameHD 

Neuer Dateiname Odd.Job.Jack.S01E02.1080p 


Benutzt die pyLoad-Events "package_finished" oder "unrar_finished", letzterer, falls die pyLoad-Unrar-Engine benutzt wird. 

WICHTIG: Die Option "Create folder for each package" "Ordner für jeden Download erstellen" in den pyLoad-Einstellungen muss aktiviert sein! 

Installationsanleitung: 

1. Installiere die benötigten Pakete sed, findutils und tr und optional nano (letzteres um die Dateien "DELNAME", "SERIEN" und "passwoerter" zu bearbeiten, funktioniert aber auch mit vi). 

ipkg update
ipkg install sed findutils nano tr gawk
ipkg upgrade 


2. Installiere Scriptpaket 

wechsle ins pyLoad-Verzeichnis "package_finished" (falls das eingebundene Unrarscript verwendet werden soll) oder "unrar_finished" (falls die pyLoad-Unrar-Engine benutzt wird) und lade das Userscript von dieser Seite herunter. 

cd ../scripts/package_finished/
wget http://pyload-runscript.googlecode.com/files/startscript.sh; chmod +x startscript.sh 


3. Anpassen der persönlichen Variablen 

nano startscript.sh 

Nachfolgende (Pfad-) Angaben sind unbedingt anzupassen!

PREFIX="/share/Public"            # dein "Home-Verzeichnis" - ANPASSEN!
DESTINATION=/share/Qmultimedia/   # dein Multimediaverzeichnis - ANPASSEN!
DESTIS=/share/Qmultimedia/Serien  # Serien-Verzeichnis - ANPASSEN!
UNRARON=1                         # Archive entpacken: ja = 1 - nein = 0
ALLLOW=0                          # Dateinamen in Kleinbuchstaben = 1
Home-Verzeichnis = hier werden (automatisch) die Dateien DELNAME SERIEN passwoerter runscript.sh unrarscript gespeichert
Multimediaverzeichnis = das Verzeichnis, wohin die heruntergeladenen, entpackten und umbenannten Dateien verschoben werden
Archive entpacken = UNRARON=1 
Archive nicht entpacken = UNRARON=0
Download-Datei in Kleinbuchstaben = ALLLOW=1
Serien-Verzeichnis = ggf. anlegen! Darin wird ein Verzeichniss erstellt und der fertige Download hineinverschoben, falls eine DL-Datei durch eine Variable im File SERIEN gefunden wird

Beispiel: steht in der Datei SERIEN die Bezeichnung deiner Lieblingsserie Benderama, das Verzeichnis ist aber noch nicht angelegt und es wird ein Download dieser Serie gestartet (Benderama.S06E16.Geister.Nachricht.German.DL.Dubbed.WS.1080p.BluRay.x264-GDR), so wird die Datei umbenannt (Benderama.S06E16.Geister.Nachricht.1080p), das Verzeichnis Benderama im Serien-Verzeichnis angelegt und die fertige Datei dorthinein verschoben. 


4. Script starten 

./startscript.sh 

Das Script läd alle benötigten Scripte und Dateien, falls nicht vorhanden, selbstständig herunter, prüft, welcher Hook gewählt wurde und passt die entsprechende Variable an. 


5. ggf. die Dateien mit den Ersetzungsvariablen / Serienvariablen / Passwörtern ändern / erweitern 

nano DELNAME
nano SERIEN
nano passwoerter


6. pyLoad neu starten, damit das Userscript geladen wird - fertig! Fröhliches Laden ;- )
