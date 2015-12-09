DELETE FROM target_bundesliga.award;
DELETE FROM target_bundesliga.coaches;
DELETE FROM target_bundesliga.plays_at;
DELETE FROM target_bundesliga.match;
DELETE FROM target_bundesliga.team_league;
DELETE FROM target_bundesliga.team;
DELETE FROM target_bundesliga.league;
DELETE FROM target_bundesliga.person_school;
DELETE FROM target_bundesliga.school;
DELETE FROM target_bundesliga.person;
DELETE FROM target_bundesliga.location;


INSERT INTO target_bundesliga.location(city, state, country)
  SELECT DISTINCT NULL, NULL, "Land"
  FROM bundesliga.spieler
  ORDER BY "Land";

INSERT INTO target_bundesliga.team(team_id, name)
  SELECT DISTINCT "V_ID", "Name"
  FROM bundesliga.verein;

-- CASE "Liga" WHEN 1 THEN '1. Bundesliga'
--                               WHEN 2 THEN '2. Bundesliga'
--                               WHEN 3 THEN '3. Bundesliga'
--                               ELSE NULL
--                   END liga

INSERT INTO target_bundesliga.league(name, year, sport)
  SELECT DISTINCT "Liga" liga, 
                  2011, 
                  'soccer'
  FROM bundesliga.verein
  ORDER BY liga;

INSERT INTO target_bundesliga.team_league(team_id, league_id)
  SELECT team.team_id, league.league_id
  FROM bundesliga.verein, target_bundesliga.team, target_bundesliga.league
  WHERE verein."Name" = team.name
    AND (verein."Liga" :: text) = league.name;

INSERT INTO target_bundesliga.match(league_id, team1, team2, date, points1, points2)
  SELECT league.league_id, heim."V_ID", gast."V_ID", spiel."Datum", spiel."Tore_Heim", spiel."Tore_Gast"
  FROM target_bundesliga.league, bundesliga.verein heim, bundesliga.verein gast, bundesliga.spiel, target_bundesliga.team_league
  WHERE heim."V_ID" = spiel."Heim"
    AND gast."V_ID" = spiel."Gast"
    AND heim."V_ID" = team_league.team_id
    AND league.league_id = team_league.league_id;

INSERT INTO target_bundesliga.person(person_id, first_name, last_name, nick_name, birth_date, birth_location, death_date, death_location, weight, height)
  SELECT "Spieler_ID", NULL, "Spieler_Name", NULL, (NULL :: date), location.location_id, (NULL :: date), (NULL :: int), (NULL :: real), (NULL :: real)
  FROM bundesliga.spieler, target_bundesliga.location
  WHERE spieler."Land" = location.country
    AND length(regexp_replace(spieler."Spieler_Name", '[^ ]', '', 'g')) = 0;

INSERT INTO target_bundesliga.person(person_id, first_name, last_name, nick_name, birth_date, birth_location, death_date, death_location, weight, height)
  SELECT"Spieler_ID", split_part("Spieler_Name", ' ', 1), split_part("Spieler_Name", ' ', 2), NULL, (NULL :: date), location.location_id, (NULL :: date), (NULL :: int), (NULL :: real), (NULL :: real)
  FROM bundesliga.spieler, target_bundesliga.location
  WHERE spieler."Land" = location.country
    AND length(regexp_replace(spieler."Spieler_Name", '[^ ]', '', 'g')) = 1;


INSERT INTO target_bundesliga.person(person_id, first_name, last_name, nick_name, birth_date, birth_location, death_date, death_location, weight, height)
  SELECT "Spieler_ID", split_part("Spieler_Name", ' ', 1) || ' ' || split_part("Spieler_Name", ' ', 2), split_part("Spieler_Name", ' ', 3), NULL, (NULL :: date), location.location_id, (NULL :: date), (NULL :: int), (NULL :: real), (NULL :: real)
  FROM bundesliga.spieler, target_bundesliga.location
  WHERE spieler."Land" = location.country
    AND length(regexp_replace(spieler."Spieler_Name", '[^ ]', '', 'g')) = 2;

INSERT INTO target_bundesliga.person(person_id, first_name, last_name, nick_name, birth_date, birth_location, death_date, death_location, weight, height)
  SELECT "Spieler_ID", split_part("Spieler_Name", ' ', 1) || ' ' || split_part("Spieler_Name", ' ', 2) || ' ' || split_part("Spieler_Name", ' ', 3), split_part("Spieler_Name", ' ', 4), NULL, (NULL :: date), location.location_id, (NULL :: date), (NULL :: int), (NULL :: real), (NULL :: real)
  FROM bundesliga.spieler, target_bundesliga.location
  WHERE spieler."Land" = location.country
    AND length(regexp_replace(spieler."Spieler_Name", '[^ ]', '', 'g')) = 3;

INSERT INTO target_bundesliga.plays_at(person_id, team_id, league_id)
  SELECT spieler."Spieler_ID", team_league.team_id, team_league.league_id
  FROM bundesliga.spieler, 
    (SELECT team_id, team_name, league.league_id, league.name league_name, league.year league_year
     FROM
      (SELECT team.team_id, team.name team_name, team_league.league_id
       FROM target_bundesliga.team INNER JOIN target_bundesliga.team_league ON team.team_id = team_league.team_id
      ) team_league INNER JOIN target_bundesliga.league ON team_league.league_id = league.league_id
    ) team_league
  WHERE spieler."Vereins_ID" = team_league.team_id;