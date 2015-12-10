
if [ $# -lt 1 ]; then
  echo "Usage: $0 <db>"
  exit 1
fi
DB=$1

psql $DB < create_source_schemas.sql
psql $DB < create_integrated_schema.sql
./create_targets.sh $DB

for IMPORTER in imports/*; do
  echo $IMPORTER
  psql $DB < $IMPORTER
done
