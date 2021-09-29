#! /bin/bash

EMAIL_ID= #<EMAIL_ID_SEND_AN_EMAIL>
EMAIL_PASS= #<EMAIL_ID_PASSWORD>
EMAIL_FILE=backup.txt
BACKUP_LOG=db_backup.log
DB_NAME= #<DATABASE_NAME>
DB_USER= #<DATABASE_USER>
DB_PASS= #<DATABASE_USER_PASSWORD>
DB_BACKUP_PATH= #<ABSOLUTE_PATH_TO_BACKUP_DIR>
RCPT_EMAIL_ID= #<EMAIL_ID_TO_RECIEVE_AN_EMAIL>
CLIENT_NAME_AND_ENVIRONMENT= #<CLIENT_NAME_AND_ENVIRONMENT_NAME>

backupStartTime() {
    echo "-----------------------------------------------------" &>> $BACKUP_LOG
    echo "DB backup start time:" `date +%x-%r` &>> $BACKUP_LOG
}

backupEndTime() {
    echo "DB backup end time:" `date +%x-%r` &>> $BACKUP_LOG
    echo "-----------------------------------------------------" &>> $BACKUP_LOG
}
backupFailedTime() {
    echo "DB backup fail time:" `date +%x-%r` &>> $BACKUP_LOG
    echo "-----------------------------------------------------" &>> $BACKUP_LOG
}

backupStartTime

cat > $EMAIL_FILE << EOF
Subject: [ IMPORTATNT ALERT ] : '$CLIENT_NAME_AND_ENVIRONMENT' : DB Backup Script Failed!

Hello Buid Team,

Please check the below errors

==================================================================================================================

EOF

set -o pipefail

mysqldump -u$DB_USER -p$DB_PASS --single-transaction --skip-lock-tables --routines $DB_NAME --verbose &>> $EMAIL_FILE | gzip > $DB_BACKUP_PATH/OPENSPECIMEN_`date +\%d-\%m-\%Y`.SQL.gz
DUMP_EXIT_CODE=$?

cat >> $EMAIL_FILE << EOF

===================================================================================================================

Thanks,
Backup Monitor
EOF

if [[ $DUMP_EXIT_CODE -ne 0 ]]
then
  sed -n '6,14p' $EMAIL_FILE &>> $BACKUP_LOG
  curl --ssl-reqd --url 'smtps://smtp.gmail.com:465' -u $EMAIL_ID:$EMAIL_PASS --mail-from $EMAIL_ID --mail-rcpt $RCPT_EMAIL_ID --upload-file $EMAIL_FILE
  backupFailedTime
else
  backupEndTime
fi

rm backup.txt

find $DB_BACKUP_PATH -mtime +30 -exec rm {} \;
