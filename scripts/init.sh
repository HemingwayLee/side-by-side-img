#!/bin/bash

until PGPASSWORD=${POSTGRES_PASSWORD} psql -h ${POSTGRES_HOST} -p 5432 -U postgres -c "\q"; do
  >&2 echo "Postgres is not available, sleep..."
  sleep 1
done

>&2 echo "Postgres is up"

pwd
ls

cd /home/proj/webapp/
python3 manage.py makemigrations main
python3 manage.py migrate

COUNT=$(PGPASSWORD=${POSTGRES_PASSWORD} psql -h ${POSTGRES_HOST} -p 5432 -U postgres -d ${POSTGRES_DB_NAME} -tAc 'select count(*) from auth_user;')
if [ "$COUNT" -gt "0" ] ; then
  >&2 echo "Superuser Exist!!! This is hotfix mode"
  >&2 echo "No need to create superuser"
else
  >&2 echo "Superuser NOT Exist!!! This is fresh install mode"
  cd /home/proj/scripts/
  ./create_superuser.sh

  >&2 echo "Remove leftovers"
  cd /home/proj/webapp/media/
  rm -rf ./*/
  rm debug.log
  ls
fi

cd /home/proj/webapp/
python3 manage.py runserver 0.0.0.0:8000
