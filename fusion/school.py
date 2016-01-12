from utils import find_duplicates

def merge_schools(cursor):
    schools = _get_schools(cursor)
    clean_schools = schools

    duplicate_map, duplicates_found = find_duplicates(clean_schools, _compare, "location_id")

    return duplicate_map
    
def _compare(a, b):
    return False

def _get_schools(cursor):
    query = "SELECT school_id, name, location_id FROM target.school ORDER BY name"
    cursor.execute(query)
    result = cursor.fetchall()

    result = [{"school_id": school_id, "name": name, "location_id": location_id} for (school_id, name, location_id) in result]
    return result