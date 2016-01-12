from utils import find_duplicates
from resources import TEAM_CODES


def merge_teams(cursor):
    teams = _get_teams(cursor)
    clean_teams = _clean_teams(teams)

    duplicate_map, duplicates_found = find_duplicates(clean_teams, _compare, "team_id")

    return duplicate_map


def _compare(a, b):
    if a["name"] and b["name"]:
        identical = (a["name"].lower()==b["name"].lower())
        fc = (a["name"].lower() + "fc" == b["name"].lower()) \
            or (a["name"].lower() == b["name"].lower() + " fc")
        ac = (a["name"].lower() + "ac" == b["name"].lower()) \
            or (a["name"].lower() == b["name"].lower() + " ac")
        return identical or fc or ac
    return False


def _get_teams(cursor):
    query = "SELECT team_id, name FROM target_merged.team ORDER BY name"
    cursor.execute(query)
    result = cursor.fetchall()

    result = [{"team_id": team_id, "name": name} for (team_id, name) in result]
    return result


def _clean_teams(teams):
    for team in teams:
        if team["name"]:
            if team["name"] in TEAM_CODES:
                team["name"] = TEAM_CODES[team["name"]]
            team["name"] = team["name"].strip()
    return teams
