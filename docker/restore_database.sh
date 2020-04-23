#!/usr/bin/env bash
echo "Restoring database"
psql -U postgres -c "CREATE DATABASE ${DBNAME}"
#pg_restore -v -d ${DBNAME} /tmp/${FILE} > /tmp/log
psql -U postgres -d covidtracker -1 -f /tmp/${FILE}
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE ${DBNAME} TO postgres"
echo "Database restored successfully"
