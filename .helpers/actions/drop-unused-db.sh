#!/bin/bash

psql postgres << EOF
\x

SELECT datname
FROM pg_database
WHERE datname NOT IN (
    SELECT datname
    FROM pg_stat_database
    WHERE (now() - pg_stat_database.last_stat_reset) > interval '${RETENTION_INTERVAL}'
)
AND has_database_privilege(datname, 'CONNECT');
EOF
