import psycopg2

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

    print("{0} duplicates found for {1}".format(duplicates_found, id_attribute))
    print duplicate_map

    return duplicate_map, duplicates_found


def update_ids(mappings, conn, table, update_field):
    cursor = conn.cursor()
    query_template = "UPDATE target_merged.{0} SET {1}={2} WHERE {1}={3}"
    for duplicate_id in mappings:
        original_id = mappings[duplicate_id][0]
        query = query_template.format(table, update_field, original_id, duplicate_id)
        try:
            cursor.execute(query)
            conn.commit()
        except psycopg2.IntegrityError as e:
            conn.rollback()
            print e
            print query


def update_rows(mappings, conn, table, fields):
    cursor = conn.cursor()
    query_template = "UPDATE target_merged.{0} SET {1} WHERE {2}={3}"
    for duplicate_id in mappings:
        mapping = mappings[duplicate_id]
        set_statement = ", ".join([field + "='" + str(value).replace("'", "") + "'" for field, value in zip(fields[1:], mapping[1:]) if value is not None and len(str(value)) > 0])
        if len(set_statement) > 0:
            query = query_template.format(table, set_statement, fields[0], duplicate_id)
            try:
                cursor.execute(query)
                conn.commit()
            except psycopg2.IntegrityError as e:
                conn.rollback()
                print e
                print query


def delete_duplicates(mappings, conn, table, field):
    cursor = conn.cursor()
    delete_template = "DELETE FROM target_merged.{0} CASCADE WHERE {1}={2}"
    for duplicate_id in mappings:
        delete = delete_template.format(table, field, duplicate_id)
        cursor.execute(delete)
        conn.commit()

