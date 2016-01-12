#!/usr/bin/python

import location
import psycopg2
import sys


def main(db, db_user):
    conn = psycopg2.connect("dbname={0} user={1}".format(db, db_user))
    cursor = conn.cursor()
    with cursor as cur:
        location_mappings = location.merge_locations(cur)
        change_locations_school(location_mappings, cur)

        # school_mappings = school.merge_schools(cur, location_mappings)

        conn.commit()


def change_locations_school(location_mappings, cursor):
    query_template = "UPDATE target_merged.school set location_id={0} WHERE location_id={1}"
    for duplicate_id in location_mappings:
        original_id = location_mappings[duplicate_id]
        query = query_template.format(original_id, duplicate_id)
        #cursor.execute(query)


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: fusion.py <db> <db-user>")
        sys.exit(0)
    main(sys.argv[1], sys.argv[2])
