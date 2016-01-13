from enum import IntEnum
import psycopg2

class Attr(IntEnum):
    person_id = 0
    first_name = 1
    last_name = 2
    nick_name = 3
    birthdate = 4
    birth_location = 5
    deathdate = 6
    death_location = 7
    weight = 8
    height = 9

def _get_sorted_persons(cursor):
    query = "SELECT * FROM target.person ORDER BY last_name ASC, first_name ASC, birth_date ASC"
    cursor.execute(query)
    return cursor.fetchall()

def scrub_data(persons):
    def scrub(person):
        birthdate = "" if person[Attr.birthdate] == "0001-01-01 BC" else person[Attr.birthdate]
        return person[:Attr.birthdate] + (birthdate,) + person[Attr.birth_location:] 

    return [scrub(person) for person in persons]

def merge(cursor, window_size = 50):
    register_bc_date(cursor)
    persons = _get_sorted_persons(cursor)
    persons = scrub_data(persons)
    duplicates_found = []
    duplicates_map = {}

    for window_start in range(0, len(persons) - window_size):
        if window_start == 0:
            for i in range(window_start, window_start + window_size - 1):
                for j in range(i + 1, window_start + window_size):
                    if is_duplicate(persons[i], persons[j]):
                        duplicates_found.append((i,j))
        else:
            j = window_start + window_size - 1
            for i in range(window_start, window_start + window_size - 1):
                if is_duplicate(persons[i], persons[j]):
                    duplicates_found.append((i,j))

    print len(duplicates_found)
    for a, b in duplicates_found:
        #transitivity
        if b not in duplicates_map and a in duplicates_map:
            c = duplicates_map[a]
            duplicates_map[b] = c
        elif b not in duplicates_map:
            duplicates_map[b] = a

    #merge records
    for duplicate_idx, master_idx in duplicates_map.items():
        duplicate = persons[duplicate_idx]
        master = persons[master_idx]
        
        update = tuple((master_attr if master_attr else duplicate_attr for master_attr, duplicate_attr in zip(master, duplicate)))
        print duplicate
        print master
        print update
        print ""

        persons[master_idx] = update




def is_duplicate(a, b, threshold=0.7):
    a_set = set(a[1:Attr.birthdate] + a[Attr.weight:])
    b_set = set(b[1:Attr.birthdate] + a[Attr.weight:])

    a_set.discard(None)
    b_set.discard(None)

    # print a_set
    # print b_set
    jaccard =  len(a_set.intersection(b_set)) / float(len(a_set.union(b_set)))
    # print jaccard
    # print ""

    return jaccard >= threshold

# This function dafines types cast, and as returned database literal is already a string, no
# additional logic required.
def cast_bc_date(value, cursor):
    return value

def register_bc_date(cursor):
    cursor.execute('SELECT NULL::date')
    psql_date_oid = cursor.description[0][1]

    BcDate = psycopg2.extensions.new_type((psql_date_oid,), 'DATE', cast_bc_date)
    psycopg2.extensions.register_type(BcDate)