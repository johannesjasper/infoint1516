#!/usr/bin/python

import location
import team
import league
import psycopg2
import sys
from utils import update_ids, delete_duplicates


def main(db, db_user):
    conn = psycopg2.connect("dbname={0} user={1}".format(db, db_user))
    cursor = conn.cursor()
    with cursor as cur:
        team_mappings = team.merge_teams(cur)
        update_ids(team_mappings, cur, "team_league", "team_id")
        update_ids(team_mappings, cur, "match", "team_1")
        update_ids(team_mappings, cur, "match", "team_2")
        delete_duplicates(team_mappings, cur, "team", "team_id")

        location_mappings = location.merge_locations(cur)

        update_ids(location_mappings, cur, "school", "location_id")
        update_ids(location_mappings, cur, "person", "birth_location")
        update_ids(location_mappings, cur, "person", "death_location")
        delete_duplicates(location_mappings, cur, "location", "location_id")





        # school_mappings = school.merge_schools(cur, location_mappings)

        league_mappings = league.merge(cur)




        conn.commit()





if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: fusion.py <db> <db-user>")
        sys.exit(0)
    main(sys.argv[1], sys.argv[2])
