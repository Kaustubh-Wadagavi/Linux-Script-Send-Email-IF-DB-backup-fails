#! /bin/bash

mysql -uroot -psecrete os_mysql -e 'select 1'

commandExitCode=$?

if [[ $commandExitCode -ne 0 ]]
then
    sudo systemctl start mysql
    echo 'Starting MySQL'
fi
