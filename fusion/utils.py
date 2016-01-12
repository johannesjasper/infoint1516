def find_duplicates(list, compare, id_attribute):
    duplicate_map = {}
    duplicates_found = 0

    for i in range(len(list)):
        a = list[i]
        for j in range(i+1, len(list)):
            b = list[j]
            if compare(a, b):
                duplicates_found += 1
                # map id of b to id of a
                if b[id_attribute] in duplicate_map:
                    duplicate_map[b[id_attribute]].append(a[id_attribute])
                else:
                    duplicate_map[b[id_attribute]] = [a[id_attribute]]

    print("{0} duplicates found".format(duplicates_found))
    print duplicate_map

    return duplicate_map, duplicates_found


def update_ids(mappings, cursor, table, update_field):
    query_template = "UPDATE target_merged.{0} set {1}={2} WHERE {1}={3}"
    for duplicate_id in mappings:
        original_id = mappings[duplicate_id][0]
        query = query_template.format(table, update_field, original_id, duplicate_id)
        cursor.execute(query)


def delete_duplicates(mappings, cursor, table, field):
    delete_template = "DELETE FROM target_merged.{0} WHERE {1}={2}"
    for duplicate_id in mappings:
        delete = delete_template.format(table, field, duplicate_id)
        cursor.execute(delete)

