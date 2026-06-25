#!/bin/bash
echo "I'm still standing!!!"
ORIGINE=/home/$USER/sorgente
DESTINAZIONE=/home/$USER/destinazione
LOG_FILE=/home/$USER/destinazione/log_file.txt
NOME_FILE=backup_script.tar.gz
TERRA_DI_MEZZO=/home/$USER/terra_di_mezzo

scrivi_log(){
  echo "$(date '+%y-%m-%d %H:%M:%S') -$1" >> "$LOG_FILE"
}

if [ ! -d $TERRA_DI_MEZZO ]; then
  mkdir -p $TERRA_DI_MEZZO
fi
if [ ! -d $ORIGINE ]; then
  mkdir -p $ORIGINE
fi
if [ ! -d $DESTINAZIONE ]; then
  mkdir -p $DESTINAZIONE
fi
if [ ! -f $LOG_FILE ]; then
  touch $LOG_FILE
fi


scrivi_log "INIZIO PROCESSO DI BACKUP"

dimensione_sorgente=$(du -sk "$ORIGINE" | cut -f1)
spazio_disponibile_terra=$(df -k "$TERRA_DI_MEZZO" | tail -1 | awk '{print $4}')

if [ "$dimensione_sorgente" -gt "$spazio_disponibile_terra" ]; then
  scrivi_log "ERRORE CRITICO: Spazio insufficiente nella Terra di Mezzo."
  echo "Errore: Spazio insufficiente nella Terra di Mezzo."
  exit 1
fi

scrivi_log "Compressione in corso nella Terra di Mezzo"
tar -czf "$TERRA_DI_MEZZO/$NOME_FILE" "$ORIGINE" 2>> "$LOG_FILE"


if [ $? -eq 0 ]; then
  scrivi_log "Compressione riuscita."
  dimensione_file=$(du -sk "$TERRA_DI_MEZZO/$NOME_FILE" | cut -f1)
  spazio_disponibile=$(df -k "$DESTINAZIONE" | tail -1 | awk '{print $4}')

  if [ "$dimensione_file" -lt "$spazio_disponibile"  ]; then
    scrivi_log "Spazio sufficiente. Spostamento in corso..."
    mv "$TERRA_DI_MEZZO/$NOME_FILE" "$DESTINAZIONE/"
    scrivi_log "BACKUP COMPLETATO CON SUCCESSO"
    echo "Backup completato."
  else
    scrivi_log "ERRORE:Spazio insufficiente nella destinazione. Il file resta nella Terra di Mezzo."
    echo "ERRORE: Spazio su disco insufficiente nella destinazione."
    exit 1
  fi
else
  scrivi_log "ERRORE: Compressione fallita."
  exit 1
fi

exit 0
