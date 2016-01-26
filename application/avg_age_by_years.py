import psycopg2
import sys
import matplotlib.pyplot as plt
import numpy as np

class T:
    sport = 0
    year = 1
    team_name = 2
    avg_age = 3

query = """SELECT M.sport, M.year, M.name as team_name, round(cast(avg(M.age) AS NUMERIC), 2)
FROM
    (SELECT P.person_id, P.first_name, P.last_name, P.birth_date, L.sport, L.year, T.name, L.year - EXTRACT(YEAR FROM P.birth_date) AS age
    FROM target_merged.person P, target_merged.plays_at P_A, target_merged.league L, target_merged.team T
    WHERE P.birth_date is not NULL
      AND P.birth_date <> '0001-01-01'
      AND P.birth_date <> '0001-01-01 BC'
      AND P.person_id = P_A.person_id
      AND P_A.league_id = L.league_id
      AND P_A.team_id = T.team_id
    ORDER BY L.year ASC) M
GROUP BY year, name, sport
ORDER BY year
"""

def main(db, db_user):
    conn = psycopg2.connect("dbname={0} user={1}".format(db, db_user))
    cursor = conn.cursor()
    cursor.execute(query)
    result = cursor.fetchall()
    colors = {"basketball": "red", "football": "green", "hockey": "blue", "soccer": "purple"}
    for sport in ["basketball", "football", "hockey", "soccer"]:
        data = filter(lambda x: x[T.sport] == sport, result)
        print sport, len(data)

        x = [data_point[T.year] for data_point in data]
        y = [data_point[T.avg_age] for data_point in data]
        plt.scatter(x, y, c = colors[sport], label = sport, edgecolors="none")

    plt.xlim([1900,2020])
    plt.xticks(np.arange(1900, 2020+1, 5.0))
    plt.legend()
    plt.grid(True)
    plt.show()



if __name__ == '__main__':
    if len(sys.argv) < 3:
        print("Usage: fusion.py <db> <db-user>")
        sys.exit(0)
    main(sys.argv[1], sys.argv[2])
