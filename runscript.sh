#!/bin/sh

#---------------------------------------------------------------------------
#------- Script "bereinigt" Datei / Ordner -  Namen und entfernt
#------- ungewollte u. unoetige Dateien und Dateinamen-Parts wie
#------- Scene-Tags oder Sprachangaben und bringt die Dateien in
#------- eine saubere Dateikultur
#-------
#------- Initial-Script fuer pyLoad "package_finished" / "unrar_finished"
#------- 
#------- aktuelle "ipkg tr" "ipkg sed" "ipkg find" Pakete vorausgesetzt!
#------- "ipkg update" "ipkg install tr sed find"
#---------------------------------------------------------------------------

PATH=/opt/bin:/opt/sbin:/bin:/usr/bin

#---------------------------------------------------------------------------
#------- finde Archive im Downloadverzeichnis und entpacke diese 
#---------------------------------------------------------------------------

for file in $(find `$UF_FOLDER/`* -iname '*.rar'); do
  let COUNT=COUNT+1
  echo ""$NR" Entpacke "$file"" >> $LOGFILE
  filename=`basename "$file"`
  dirname=`dirname "$file"`
  sfilename="${filename%.rar}"
  cd "$dirname"
  while true; do read password || break
    unrar x -inul -p"$password" "$filename" >/dev/null
  done < "$PASSWORDS"
  SUCCESS=$?
  if [ "$SUCCESS" -eq 0 ]; then
    sleep 1
    else
    let COUNT=COUNT-1
  fi
  UNRAR=$(/bin/ps ax | /opt/bin/grep unrar | /opt/bin/grep -v /opt/bin/grep | /usr/bin/wc -l )
  if [ $UNRAR -gt '0' ]; then
    echo ""$NR" `date` unrar aktiv" >> $LOGFILE
    UNRARP=$(/bin/ps -ef | /opt/bin/grep unrar | /opt/bin/grep -v /opt/bin/grep | /opt/bin/awk '{ printf $1 }')
    echo ""$NR" `date` PID unrar $UNRARP" >> $LOGFILE
    if [ $UNRARP -gt '0' ]; then
      PID=$UNRARP
    while [ -e /proc/$PID ]; do
      echo ""$NR" `date` warte bis unrar nicht mehr ausgefuehrt wird" >> $LOGFILE
      sleep 5
    done
    fi
    else
    sleep 5
  fi
  echo ""$NR" Entferne "$file"" >> $LOGFILE
  rm "$file"

  if [ "$COUNT" -ne 0 ]; then
   echo -e ""$NR" $COUNT Dateien gefunden, entpackt und entfernt" >> $LOGFILE
  fi
  sleep 15
done

#---------------------------------------------------------------------------
#------- entferne unnoetige Dateien und Ordner 
#------- Textdateien / Info-Dateien / Reparatur-Dateien / Untertitel ...
#---------------------------------------------------------------------------

cd "$UF_FOLDER"
find . \( -name '*.sfv' -o -name '*.nfo' -o -name '*.txt' -o -name '*.rev' -o -name '*.html' -o -name '*sample*' -o -name '*.url' \) -type f -exec rm '{}' \;
find . \( -iname 'sample' -o -iname '*imdb*' -o -iname '*subs*' -o -iname '*proof*' \) -type d -exec rm -rf '{}' \;

#---------------------------------------------------------------------------
#------- entferne Leerzeichen und ersetze Sonderzeichen mit Punkten
#---------------------------------------------------------------------------

renRecursive()
{
find `$UF_FOLDER/`* ! -name "*.sh" -type d -print | while read FILE; do
  if [ -d "$FILE" ]; then
    cd "$FILE"; renRecursive; renFiles; renFolder 
  fi
done
}

renFolder()
{
find `$UF_FOLDER/`* ! -name "*.sh" -type d -print | while read FILE; do
  if [ -d "$FILE" ]; then
  NEW=`echo "$FILE" | sed -r 's/ +/./g' | sed -r 's/-/./g;s/_/./g;s/^\.+//;s/\.+$//' | tr -s '.'`
    if [ "$NEW" != "$FILE" -a ! -f "$NEW" -a ! -d "$NEW" ]; then
      mv "$FILE" "$NEW"
    fi
  fi
done
}

renFiles()
{
find `$UF_FOLDER/`* ! -name "*.sh" -type f -print | while read FILE; do
  if [ -f "$FILE" ]; then
  NEW=`echo "$FILE" | sed -r 's/ +/./g' | sed -r 's/-/./g;s/_/./g;s/^\.+//;s/\.+$//' | tr -s '.'`
    if [ "$NEW" != "$FILE" -a ! -f "$NEW" -a ! -d "$NEW" ]; then
      mv "$FILE" "$NEW"
    fi
  fi
done
}

#---------------------------------------------------------------------------
#------- Entferne alles nach der Pixel-Angabe im Ordernamen
#---------------------------------------------------------------------------

shortenfolder()
{
find `$UF_FOLDER/`* ! -name "*.sh" -type d -print | while read FILE; do
  if [ -d "$FILE" ]; then
    NEW=`echo "$FILE" | sed 's/\.720.*//;s/\.1080.*//;s/\.72.*//;s/\.108.*//'`
    if [ "$NEW" != "$FILE" -a ! -f "$NEW" -a ! -d "$NEW" ]; then
      mv "$FILE" "$NEW"
    fi
  fi
done
}

#---------------------------------------------------------------------------
#------- aendere rekursiv alles in Kleinbuchstaben
#---------------------------------------------------------------------------

lowRecursive()
{
find `$UF_FOLDER/`* -name "*" -type d -print | while read FILE; do
  if [ -d $FILE ]; then
    cd $FILE
    lowRecursive
    lowFiles
    cd ..
  fi
done
}

lowFiles()
{
find `$UF_FOLDER/`* ! -name "*.sh" | while read FILE; do
  if [ -f $FILE -o -d $FILE ]; then
    NEW=`echo $FILE | tr 'A-Z' 'a-z'`
    if [ $NEW != $FILE -a ! -f $NEW -a ! -d $NEW ]; then
      mv "$FILE" "$NEW"
    fi
  fi
done
}

#---------------------------------------------------------------------------
#------- entferne Szene-Tags und / oder unnoetige Dateinamenteile
#---------------------------------------------------------------------------

rmTagsRecursive()
{
find `$UF_FOLDER/`* ! -name "*.sh" -type d -print | while read FILE; do
  if [ -d $FILE ]; then
    cd "$FILE"
    rmTagsRecursive
    rmTags
    cd ..
  fi
done
}

rmTags()
{
for i in `cat $DELNAME`
do
  find `$UF_FOLDER/`* ! -name "*.sh" -print | while read FILE; do
    if [ -d $FILE ]; then
      NEW=`echo $FILE | sed -r 's/'"$i"'\.//g' | sed -r 's/\.'"$i"'//g'`
      if [ $NEW != $FILE -a ! -f $NEW -a ! -d $NEW ]; then
        mv "$FILE" "$NEW"
      fi
    fi
    if [ -f $FILE ]; then
      NEW=`echo $FILE | sed -r 's/'"$i"'\.//g' | sed -r 's/'"$i"'//g'`
      if [ $NEW != $FILE -a ! -f $NEW -a ! -d $NEW ]; then
        mv "$FILE" "$NEW"
      fi
    fi
  done
done
}

#---------------------------------------------------------------------------
#------- aendere ersten Buchstaben nach einem Punkt in einen Grossbuchstaben
#---------------------------------------------------------------------------

upRecursive()
{
find `$UF_FOLDER/`* ! -name "*.sh" -type d -print | while read FILE; do
  if [ -d $FILE ]; then
    cd "$FILE"
    upRecursive
    upFolder
    upFiles
    cd ..
  fi
done
}

upFolder()
{
find `$UF_FOLDER/`* ! -name "*.sh" -type d -print | while read FILE; do
  if [ -d $FILE ]; then
    # nachfolgende Codezeile darf nicht "gelinebreakt" werden!
    NEW=`echo $FILE | sed -r 's/(\<.)/\u\1/g;s/([se][0123456789])/\u\1/g;s/Dvd/DVD/;s/Dts/DTS/;s/Hd/HD/'`
    if [ $NEW != $FILE -a ! -f $NEW -a ! -d $NEW ]; then
      mv "$FILE" "$NEW"
    fi
  fi
done
}

upFiles()
{
find `$UF_FOLDER/`* ! -name "*.sh" -type f -print | while read FILE; do
  if [ -f $FILE ]; then
    # nachfolgende Codezeile darf nicht "gelinebreakt" werden!
    NEW=`echo $FILE | sed -r 's/(\<.)/\u\1/g;s/([se][0123456789])/\U\1/g;s/Dvd/DVD/;s/Dts/DTS/;s/Hd/HD/' | sed -r 's/(\....)$/\L\1/'`
    if [ $NEW != $FILE -a ! -f $NEW -a ! -d $NEW ]; then
      mv "$FILE" "$NEW"
    fi
  fi
done
}

#---------------------------------------------------------------------------
#------- Ordner-Name = Dateiname
#---------------------------------------------------------------------------

renamefilename()
{
AnzahlDateien=`find '$UF_FOLDER' -type f | wc -1`
find `$UF_FOLDER/`* ! -name "*.sh" -type f -maxdepth 1 -print | while read i; do
  if [ $AnzahlDateien -gt 1 ]; then
    mkdir -p "${i%.*}" && mv "$i" "${i%.*}";
  else
  find `$UF_FOLDER/`* ! -name "*.sh" -type f -print | while read file; do
    dirname="$(dirname "$file")"
    new_name="${dirname##*/}"
    file_ext=${file##*.}
    if [ -n "$file_ext" -a -n "$dirname" -a -n "$new_name" ]
    then
        mv "$file" "$dirname/$new_name.$file_ext"
    fi
	done
  fi
done
}

#---------------------------------------------------------------------------
#------- Code ausfuehren
#---------------------------------------------------------------------------

renRecursive
 sleep 2
renFolder
  sleep 2
renFiles
 sleep 2
lowRecursive
 sleep 2
lowFiles
 sleep 2
rmTagsRecursive
 sleep 2
shortenfolder
  sleep 2
rmTags
  sleep 2

#if [ $ALLLOW != 1 ]; then
 sleep 2
upFolder
 sleep 2
upFiles
 sleep 2
#fi

renamefilename

#---------------------------------------------------------------------------
#------- verschiebe Dateien und Ordner ins Zielverzeichnis
#------- loesche "runscript.sh" aus dem Downloadverzeichnis
#---------------------------------------------------------------------------

sleep 5
find `$UF_FOLDER/`* -iname "Runscript.sh" -print | while read FILE; do
  rm "$FILE"
  sleep 3
done

copy2destination()
{
cd "$UF_FOLDER"
find `$UF_FOLDER/`* -type d -maxdepth 1 -print | while read FILE; do
  echo ""$NR" `date` --- mv "$FILE" "$DESTINATION"" >> $LOGFILE
  touch "$FILE"; mv "$FILE" "$DESTINATION"
  (echo "Subject: "$FILE" Download fertig"; echo "From: mail@gmail.com"; echo "To: Me <mail@gmail.com>"; echo ""; echo ""$FILE" ist da") | /usr/sbin/ssmtp mail@gmail.com
done
echo ""$NR" *** Scriptende ***" >> $LOGFILE
echo ""$NR" -----------------------------------" >>$LOGFILE
}

copyseries()
{
for SERIEN in `cat $SERIES`
do
  if [ ! -d "${DESTIS}/$SERIEN" ]; then
    echo "`date` --- "${DESTIS}/$SERIEN"" >> $LOGFILE
    cd "$DESTIS"
    echo `mkdir $SERIEN` >> $LOGFILE
  fi
	cd "$UF_FOLDER"
	find `$UF_FOLDER/`* -iname "*"$SERIEN"*" -type d -print | while read OMEGA; do
    echo ""$NR" `date` --- mv "$OMEGA" "${DESTIS}/$SERIEN"" >> $LOGFILE
    mv "$OMEGA" "${DESTIS}/$SERIEN"
		  if [ $? = "0" ] ; then
		    echo ""$NR" *** Scriptende SERIEN ***" >> $LOGFILE
		    echo ""$NR" -----------------------------------" >>$LOGFILE
			  (echo "Subject: "$OMEGA" Serien-Download fertig"; echo "From: mail@gmail.com"; echo "To: Me <mail@gmail.com>"; echo ""; echo ""$OMEGA" ist da") | /usr/sbin/ssmtp mail@gmail.com 
  	  fi
  done
done
}

copyseries
sleep 5
copy2destination

#---------------------------------------------------------------------------
#------- loesche das - leere - Downloadverzeichnis
#---------------------------------------------------------------------------

sleep 30; rmdir "$UF_FOLDER"

#---------------------------------------------------------------------------
#------- Scriptende
#---------------------------------------------------------------------------

exit 0
