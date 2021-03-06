#!/usr/bin/python

import location
import team
import school
import league
import match
import award
import person
import psycopg2
import sys
from utils import update_ids, update_rows, delete_duplicates


def main(db, db_user):
    conn = psycopg2.connect("dbname={0} user={1}".format(db, db_user))
    cursor = conn.cursor()
    with cursor as cur:
        team_mappings = team.merge_teams(cur)
        update_ids(team_mappings, conn, "match", "team1")
        update_ids(team_mappings, conn, "match", "team2")
        update_ids(team_mappings, conn, "team_league", "team_id")
        update_ids(team_mappings, conn, "coaches", "team_id")
        update_ids(team_mappings, conn, "plays_at", "team_id")
        delete_duplicates(team_mappings, conn, "match", "team1")
        delete_duplicates(team_mappings, conn, "match", "team2")
        delete_duplicates(team_mappings, conn, "coaches", "team_id")
        delete_duplicates(team_mappings, conn, "plays_at", "team_id")
        delete_duplicates(team_mappings, conn, "team_league", "team_id")
        delete_duplicates(team_mappings, conn, "team", "team_id")

        location_mappings, location_updates = location.merge_locations(cur)
        update_ids(location_mappings, conn, "school", "location_id")
        update_ids(location_mappings, conn, "person", "birth_location")
        update_ids(location_mappings, conn, "person", "death_location")
        delete_duplicates(location_mappings, conn, "location", "location_id")
        update_rows(location_updates, conn, "location", ["location_id", "city", "state", "country"])

        school_mappings = school.merge_schools(cur)
        update_ids(school_mappings, conn, "person_school", "school_id")
        delete_duplicates(school_mappings, conn, "school", "school_id")

        league_mappings = league.merge(cur)
        update_ids(league_mappings, conn, "match", "league_id")
        update_ids(league_mappings, conn, "team_league", "league_id")
        update_ids(league_mappings, conn, "plays_at", "league_id")
        update_ids(league_mappings, conn, "coaches", "league_id")
        update_ids(league_mappings, conn, "award", "league_id")
        delete_duplicates(league_mappings, conn, "league", "league_id")

        match_mappings = match.merge(cur)
        delete_duplicates(match_mappings, conn, "match", "match_id")

        award_mappings = award.merge(cur)
        delete_duplicates(award_mappings, conn, "award", "award_id")

        person_mappings, person_updates = person.merge(cur)
        print person_mappings
        delete_duplicates(person_mappings, conn, "person", "person_id")

        update_rows(person_updates, conn, "person", ["person_id", "first_name", "last_name", "nick_name", "birth_date", "birth_location", "death_date", "death_location", "weight", "height"])

        conn.commit()



if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: fusion.py <db> <db-user>")
        sys.exit(0)
    main(sys.argv[1], sys.argv[2])
