if [ $# -lt 1 ]; then
  echo "Usage: $0 <db>"
  exit 1
fi
DB=$1

pg_dump --schema='target' $DB | sed "s/target/target_merged/g" | psql  -d $DB
