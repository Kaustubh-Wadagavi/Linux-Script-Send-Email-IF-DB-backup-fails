#! /bin/bash

mysql -uroot -psecrete os_mysql -e 'select 1'

COMMAND_EXIT_CODE=$?

if [[ $COMMAND_EXIT_CODE -ne 0 ]]
then
    sudo systemctl start mysql
    echo 'Starting MySQL'
fi
