#!/bin/bash

# TODO: this job is still WIP

psql postgres << EOF
\x

SELECT datname
FROM pg_database
WHERE datname NOT IN (
    SELECT datname
    FROM pg_stat_activity
    WHERE usename = '$PGUSER' AND state = 'idle' AND (now() - pg_stat_activity.query_start) > interval '$RETENTION_INTERVAL'
)
AND datname NOT IN ('template0', 'template1', 'postgres')
AND has_database_privilege(datname, 'CONNECT');
EOF
EOF