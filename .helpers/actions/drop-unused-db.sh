#!/bin/bash

psql postgres << EOF
\x

SELECT datname
FROM pg_database
WHERE datname NOT IN (
    SELECT datname
    FROM pg_stat_bgwriter
    WHERE (now() - last_stats_reset) > interval '2 days'
)
AND has_database_privilege(datname, 'CONNECT');
EOF
