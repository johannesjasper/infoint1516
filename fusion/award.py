from utils import find_duplicates

def merge(cursor):
    awards = _get_awards(cursor)
    duplicate_map, duplicates_found = find_duplicates(awards, _compare, "award_id")

    return duplicate_map


def _get_awards(cursor):
    query = "SELECT * FROM target_merged.award ORDER BY person_id, league_id, name"
    cursor.execute(query)
    result = cursor.fetchall()

    result = [{"award_id": award_id, "person_id": person_id, "name": name, "league_id": league_id} for (award_id, person_id, name, league_id) in result]
    return result

def _compare(a, b):
    return a['person_id'] == b['person_id'] \
    	and a['league_id'] == b['league_id'] \
    	and a['name'] == b['name']

