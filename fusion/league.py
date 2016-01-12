from utils import find_duplicates

def merge(cursor):
    leagues = _get_leagues(cursor)
    duplicate_map, duplicates_found = find_duplicates(leagues, _compare, "league_id")

    return duplicate_map


def _get_leagues(cursor):
    query = "SELECT * FROM target_merged.league ORDER BY sport, year;"
    cursor.execute(query)
    result = cursor.fetchall()

    result = [{"league_id": league_id, "year": year, "sport": sport, "name": name} for (league_id, year, sport, name) in result]
    return result

def _compare(a, b):
    return a['sport'] == b['sport'] and a['year'] == b['year'] and a['name'].lower() == b['name'].lower()