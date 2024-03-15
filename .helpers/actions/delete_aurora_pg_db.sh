#!/bin/bash

psql postgres -c "DROP DATABASE IF EXISTS \"${PGDATABASE}\" WITH (FORCE);"
