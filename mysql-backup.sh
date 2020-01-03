#!/bin/bash
#----------------------------------------
# OPTIONS
#----------------------------------------
USER='root'       # MySQL User
PASSWORD='root' # MySQL Password
DAYS_TO_KEEP=0    # 0 to keep forever
GZIP=1            # 1 = Compress
BACKUP_PATH='/Users/niamulislam/scripts/backup'
#----------------------------------------

# Create the backup folder
if [ ! -d $BACKUP_PATH ]; then
  mkdir -p $BACKUP_PATH
fi

# Get list of database names
databases=`mysql -u $USER -p$PASSWORD -e "SHOW DATABASES;" | tr -d "|" | grep -v Database`

for db in $databases; do

  if [ $db == 'information_schema' ] || [ $db == 'performance_schema' ] || [ $db == 'mysql' ] || [ $db == 'sys' ]; then
    echo "Skipping database: $db"
    continue
  fi
  
  # We are saving databases in Year > Month > day directory
  day=$(date +%d)
  month=$(date +%m)
  year=$(date +%Y)
  date="$day-$month-$year"; # 14-05-2019
  FINAL_PATH=$BACKUP_PATH/$year/$month/$day

  #Create the path if not exist
  if [ ! -d $FINAL_PATH ]; then
    mkdir -p $FINAL_PATH
  fi

  if [ "$GZIP" -eq 0 ] ; then
    echo "Backing up database: $db without compression"      
    mysqldump -u $USER -p$PASSWORD --databases $db > $FINAL_PATH/$db-$date.sql
  else
    echo "Backing up database: $db with compression"
    mysqldump -u $USER -p$PASSWORD --databases $db | gzip -c > $FINAL_PATH/$db-$date.gz
  fi
done

# Delete old backups
if [ "$DAYS_TO_KEEP" -gt 0 ] ; then
  echo "Deleting backups older than $DAYS_TO_KEEP days"
  find $BACKUP_PATH/* -mtime +$DAYS_TO_KEEP -exec rm {} \;
fi
