#!/usr/bin/env bash
#docker run -it --rm --name multidb -e MYSQL_ROOT_PASSWORD=123456 -e MYSQL_DATABASE1=DB1 -e MYSQL_USER1=DB1 -e MYSQL_PASSWORD1=DB1 -e MYSQL_DATABASE2=DB2 -e MYSQL_USER2=DB2 -e MYSQL_PASSWORD2=DB2 dugi/multidb

for i in {1..10}; do
    MYSQL_DATABASE=$(v="MYSQL_DATABASE$i" && echo ${!v})
    if [ -n "$MYSQL_DATABASE" ]; then
        echo "[$i-autoconf] Creating database ${MYSQL_DATABASE}"
        echo "CREATE DATABASE IF NOT EXISTS \`$MYSQL_DATABASE\` ;" >> "/docker-entrypoint-initdb.d/$i-autoconf.sql" 
    fi

    MYSQL_USER=$(v="MYSQL_USER$i" && echo ${!v})
    MYSQL_PASSWORD=$(v="MYSQL_PASSWORD$i" && echo ${!v})
    if [ -n "$MYSQL_USER" ] && [ -n "$MYSQL_PASSWORD" ]; then
        echo "[$i-autoconf] Creating user ${MYSQL_USER}"
        echo "CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD' ;" >> "/docker-entrypoint-initdb.d/$i-autoconf.sql"
        if [ -n "$MYSQL_DATABASE" ]; then
            echo "[$i-autoconf]  Giving user ${MYSQL_USER} access to schema ${MYSQL_DATABASE}"
            echo "GRANT ALL ON \`$MYSQL_DATABASE\`.* TO '$MYSQL_USER'@'%' ;" >> "/docker-entrypoint-initdb.d/$i-autoconf.sql"
        fi

        echo "FLUSH PRIVILEGES ;" >> "/docker-entrypoint-initdb.d/$i-autoconf.sql"
    fi

    unset MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD
done

exec docker-entrypoint.sh "$@"

