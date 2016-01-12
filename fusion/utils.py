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

    print("{0} Location duplicates found".format(duplicates_found))
    print duplicate_map

    return duplicate_map, duplicates_found

