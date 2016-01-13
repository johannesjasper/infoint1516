from utils import find_duplicates

def merge_schools(cursor):
    schools = _get_schools(cursor)
    clean_schools = _clean(schools)

    duplicate_map, duplicates_found = find_duplicates(clean_schools, _compare, "school_id")

    return duplicate_map
    

def _clean(schools):

    return schools


def _compare(a, b):
    if a["name"] and b["name"]:
        if a["location_id"] == b["location_id"]:
            if a["name"].startswith(b["name"]) or b["name"].startswith(a["name"]):
                return True

    return False

def _get_schools(cursor):
    query = "SELECT school_id, name, location_id FROM target.school ORDER BY name"
    cursor.execute(query)
    result = cursor.fetchall()

    result = [{"school_id": school_id, "name": name, "location_id": location_id} for (school_id, name, location_id) in result]
    return result