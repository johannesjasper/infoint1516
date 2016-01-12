#!/usr/bin/python

import location
import league
import psycopg2


def main():
    conn = psycopg2.connect("dbname=infoint user=Florian")
    cursor = conn.cursor()
    with cursor as cur:
        location_mappings = location.merge_locations(cur)

        league_mappings = league.merge(cur)


        #school_mappings = school.merge_schools(cur, location_mappings)

        print


if __name__ == '__main__':
    main()