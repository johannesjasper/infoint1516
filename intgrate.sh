
if [ $# -lt 1 ]; then
  echo "Usage: $0 <db>"
  exit 1
fi
DB=$1

psql $DB < drop_schemas.sql
psql $DB < create_source_schemas.sql
psql $DB < create_integrated_schema.sql
./create_targets.sh $DB

for IMPORTER in imports/*; do
  echo $IMPORTER
  psql $DB < $IMPORTER
done

psql $DB < merge/initial.sql
padding=100000
for SCHEMA in target_baseballarchiv target_basketball201112 target_bundesliga target_databasebasketball target_football target_hockey target_wm2014; do
	echo $SCHEMA
	echo $padding
	sed -e "s/TARGET_SCHEMA/$SCHEMA/g" merge/stmt.txt | sed -e "s/INCREMENT/$padding/g" | psql  -d $DB
	((padding=$padding+100000))
done

./create_merged_schema.sh $DB