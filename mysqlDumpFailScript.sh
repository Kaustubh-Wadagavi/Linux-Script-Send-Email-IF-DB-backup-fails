#!/bin/bash

EMAIL_ID=
EMAIL_PASS=
OUTPUT_FILE=backup.txt

cat > $OUTPUT_FILE << EOF
Subject: [ IMPORTATNT ALERT ] : UTEXAS DB Backup Script Failed!

Hello Buid Team,

Please check the below errors

==================================================================================================================

EOF

mysqldump -uos_tester -psecret os_mysql > db.sql --verbose &>> $OUTPUT_FILE

DUMP_EXIT_CODE=$?

cat >> $OUTPUT_FILE << EOF

===================================================================================================================

Thanks,
Backup Monitor
EOF

if [[ $DUMP_EXIT_CODE -ne 0 ]]
then
  curl --ssl-reqd --url 'smtps://smtp.gmail.com:465' -u $EMAIL_ID:$EMAIL_PASS --mail-from $EMAIL_ID --mail-rcpt '<EMAIL_ID_TO_RECIEVE_FAILED_EMAIL>' --upload-file backup.txt
fi
rm backup.txt

find /backup directory path/ -mtime +30 -exec rm {} \;
