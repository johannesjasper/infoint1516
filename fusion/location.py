import resources
from utils import find_duplicates, update_rows

def merge_locations(cursor):
    locations = _get_locations(cursor)
    clean_locations = _clean(locations)

    update_map = {}
    for row in clean_locations:
        update_map[row["location_id"]] = (row["location_id"], row["city"], row["state"], row["country"])

    duplicate_map = {}
    duplicates_found = 0

    duplicate_map, duplicates_found = find_duplicates(clean_locations, _compare, "location_id")

    return duplicate_map, update_map


def _compare(a, b):

    if (a["city"] and b["city"]) and (a["city"][0] is not b["city"][0]):
        return False

    if (a["city"] and b["city"]) and (a["city"].lower() == b["city"].lower()):
        if (a["state"] and b["state"]) and (a["state"].lower() == b["state"].lower()):
            if (a["country"] and b["country"]) and (a["country"].lower() == b["country"].lower()):
                return True
    return False


def _get_locations(cursor):
    query = "SELECT location_id, city, state, country FROM target_merged.location ORDER BY city"
    cursor.execute(query)
    result = cursor.fetchall()

    result = [{"location_id": location_id, "city": city, "state": state, "country": country} for (location_id, city, state, country) in result]
    return result


def _clean(locations):
    for loc in locations:

        if loc["city"]:
            if loc["city"].startswith("(ht)"):
                loc["city"] = loc["city"][4:]
            loc["city"] = loc["city"].strip()

        if loc["state"]:
            loc["state"].strip()

        if loc["country"]:
            if loc["country"].strip() in resources.COUNTRY_CODES:
                loc["country"] = resources.COUNTRY_CODES[loc["country"].strip()]
            loc["country"].strip()
    return locations