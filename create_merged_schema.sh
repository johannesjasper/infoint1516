if [ $# -lt 1 ]; then
  echo "Usage: $0 <db>"
  exit 1
fi
DB=$1

psql $DB -c "DROP SCHEMA target_merged CASCADE"
pg_dump --schema='target' $DB | sed "s/target/target_merged/g" | psql  -d $DB
psql $DB < fusion/prepare_db.sql