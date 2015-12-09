
if [ $# -lt 1 ]; then
  echo "Usage: $0 <db>"
  exit 1
fi
DB=$1

for SCHEMA in baseballarchiv basketball basketball201112 bundesliga databasebasketball football hockey nba_biographical wm2014; do
  psql infoint -c "DROP SCHEMA target_$SCHEMA CASCADE"
  pg_dump --schema='target' $DB | sed "s/target/target_$SCHEMA/g" | psql  -d $DB
done
