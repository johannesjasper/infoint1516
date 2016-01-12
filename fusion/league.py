
def merge(cursor):
    leagues = _get_leagues(cursor)

    duplicate_map = {}
    duplicates_found = 0

    for i in range(len(leagues)):
        a = leagues[i]
        for j in range(i+1, len(leagues)):
            b = leagues[j]

            if _compare(a, b):
                duplicates_found += 1
                if b["league_id"] in duplicate_map:
                    duplicate_map[b["league_id"]].append(a["league_id"])
                else:
                    duplicate_map[b["league_id"]] = [a["league_id"]]

    print("{0} League duplicates found".format(duplicates_found))
    print duplicate_map

    return duplicate_map


def _get_leagues(cursor):
    query = "SELECT * FROM target_merged.league ORDER BY sport, year;"
    cursor.execute(query)
    result = cursor.fetchall()

    result = [{"league_id": league_id, "year": year, "sport": sport, "name": name} for (league_id, year, sport, name) in result]
    return result

def _compare(a, b):
    return a['sport'] == b['sport'] and a['year'] == b['year'] and a['name'].lower() == b['name'].lower()