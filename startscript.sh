#!/bin/sh

#-----------------------------------------------------------------------
#----- Scriptstart
#-----------------------------------------------------------------------

CHKDIR="$(basename `pwd` )"
if [ $CHKDIR = "unrar_finished" ]; then
UF_FOLDER=$1
else
UF_FOLDER=$3
fi

#-----------------------------------------------------------------------
#----- nachfolgende Pfadangaben bitte anpassen
#-----------------------------------------------------------------------

PATH=/opt/bin:/opt/sbin:/bin:/usr/bin
PREFIX="/share/Public"            	# dein "Home-Verzeichnis" - ANPASSEN!
RUNSCRP=${PREFIX}/runscript.sh    	# Pfad zum runscript 
UNRARALL=${PREFIX}/unrarscript    	# Pfad zum unrarscript 
DESTINATION=/share/Lichtspielhaus/   	# dein Downloadverzeichnis - ANPASSEN!
DESTIS="/share/Lichtspielhaus/SERIEN"  	# Serien-Verzeichnis - ANPASSEN!
LOGFILE=${PREFIX}/LOG         	  	# Logfile-Pfad
UNRARON=1                         	# Archive entpacken: ja = 1 - nein = 0
ALLLOW=0                         	# Dateinamen in Kleinbuchstaben = 1
DELNAME=${PREFIX}/DELNAME         	# Datei mit Ersetzungsvariablen 
SERIES=${PREFIX}/SERIEN           	# Datei mit Serienvariablen
PASSWORDS=${PREFIX}/passwoerter   	# Datei mit Archiv-Passwoertern 

#-----------------------------------------------------------------------
#----- exportiere personalisierte Angaben 
#-----------------------------------------------------------------------

NR=$1

export UF_FOLDER
export DESTINATION
export DESTIS
export DELNAME
export SERIES
export LOGFILE
export PASSWORDS
export ALLLOW
export NR 

#-----------------------------------------------------------------------
#----- Logfile-Ausgabe, setze "#" um Log zu deaktivieren
#-----------------------------------------------------------------------

echo ""$NR" `date`" >>$LOGFILE
echo ""$NR" Scriptname : $0" >>$LOGFILE
echo ""$NR" 1. Argument: $1" >>$LOGFILE
echo ""$NR" 2. Argument: $2" >>$LOGFILE
echo ""$NR" 3. Argument: $3" >>$LOGFILE

#-----------------------------------------------------------------------
#----- Check ob Argumente uebergeben und \$RUNSCRP vorhanden
#-----------------------------------------------------------------------

if [ "$#" = 0 ]; then
  STRNSCRP=0
  UNRARON=0
  UF_FOLDER=$PREFIX/dummydir
  cd $PREFIX
   if [ ! -d "$PREFIX/dummydir" ]; then
  mkdir dummydir
   fi
else
  STRNSCRP=1
fi

if [ ! -f $RUNSCRP ]; then
cd "$PREFIX"
wget http://pyload-runscript.googlecode.com/files/runscript.sh
chmod +x runscript.sh
fi

if [ ! -f $UNRARALL ]; then
cd "$PREFIX"
wget http://pyload-runscript.googlecode.com/files/unrarscript
chmod +x unrarscript
fi

if [ ! -f $SERIES ]; then
cd "$PREFIX"
wget http://pyload-runscript.googlecode.com/files/SERIES
fi

if [ ! -f $DELNAME ]; then
cd "$PREFIX"
wget http://pyload-runscript.googlecode.com/files/DELNAME
fi

if [ ! -f $PASSWORDS ]; then
cd "$PREFIX"
touch passwoerter
fi

#-----------------------------------------------------------------------
#----- Starte Haupt-Script
#-----------------------------------------------------------------------

PROZESS_US=$(ps ax | grep runscript.sh | grep -v grep | wc -l ); 
  if [ $PROZESS_US -gt '0' ]; then
#	echo "`date` runscript.sh aktiv" >> $LOGFILE
	PROZESSID_US=$(ps -ef | grep runscript.sh | grep -v 'grep' | awk '{ printf $1 }')
#	echo "`date` runscript.sh PID: $PROZESSID_US" >> $LOGFILE
	PID1=$PROZESSID_US
	while [ -e /proc/$PID1 ]; do 
 	sleep 25
#  	echo "`date` warte bis runscript.sh nicht mehr ausgefuehrt wird" >> $LOGFILE
 	done
    	  if [ $? = 0 ] ; then
  	    cp $RUNSCRP "$UF_FOLDER/"
  	    cd "$UF_FOLDER"
  	    ./runscript.sh &
    	  fi
  else
	cp $RUNSCRP "$UF_FOLDER/"
        cd "$UF_FOLDER"
        ./runscript.sh &
	echo ""$NR" `date` runscript.sh nicht aktiv - starte Script" >> $LOGFILE

  fi

#fi

#-----------------------------------------------------------------------
#----- Beende das Script
#-----------------------------------------------------------------------

if [ $STRNSCRP = 0 ]; then
  echo "`date` --- keine Argumente uebergeben, beende Script ---" >> $LOGFILE
  echo "--------------------------------------------------------" >> $LOGFILE
  cd "$PREFIX"
  rmdir dummydir
  exit 0
fi

exit 0

#-----------------------------------------------------------------------
#----- Scriptende
#-----------------------------------------------------------------------
