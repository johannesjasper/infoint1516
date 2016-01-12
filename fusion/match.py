from utils import find_duplicates

def merge(cursor):
    matches = _get_matches(cursor)
    duplicate_map, duplicates_found = find_duplicates(matches, _compare, "league_id")

    return duplicate_map


def _get_matches(cursor):
    query = "SELECT * FROM target_merged.match ORDER BY date, team1, team2, points1, points2;"
    cursor.execute(query)
    result = cursor.fetchall()

    result = [{"match_id": match_id, "league_id": league_id, "team1": team1, "team2": team2, "date": date, "points1": points1, "points2": points2} for (match_id, league_id, team1, team2, date, points1, points2) in result]
    return result

def _compare(a, b):
    return a['date'] == b['date'] \
    	and a['team1'] == b['team1'] \
    	and a['team2'] == b['team2'] \
    	and a['points1'] == b['points1'] \
    	and a['points2'] == b['points2']

