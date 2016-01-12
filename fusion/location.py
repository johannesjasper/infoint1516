import country_codes


def merge_locations(cursor):
    locations = _get_locations(cursor)[:1000]
    clean_locations = _clean(locations)

    duplicate_map = {}
    duplicates_found = 0

    for i in range(len(clean_locations)):
        a = clean_locations[i]
        for j in range(i+1, len(clean_locations)):
            b = clean_locations[j]
            if (a["city"] and b["city"]) and (a["city"][0] is not b["city"][0]):
                break
            if _compare(a, b):
                duplicates_found += 1
                # map location_id of b to location_id of a
                if b["location_id"] not in duplicate_map:
                    duplicate_map[b["location_id"]] = a["location_id"]

    print("{0} Location duplicates found".format(duplicates_found))

    return duplicate_map


def _compare(a, b):

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
            if loc["country"].strip() in country_codes.COUNTRY_CODES:
                loc["country"] = country_codes.COUNTRY_CODES[loc["country"].strip()]
            loc["country"].strip()
    return locations