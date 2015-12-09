DELETE FROM target_basketball.award;
DELETE FROM target_basketball.coaches;
DELETE FROM target_basketball.plays_at;
DELETE FROM target_basketball.match;
DELETE FROM target_basketball.team_league;
DELETE FROM target_basketball.team;
DELETE FROM target_basketball.league;
DELETE FROM target_basketball.person_school;
DELETE FROM target_basketball.school;
DELETE FROM target_basketball.person;
DELETE FROM target_basketball.location;

-- ALTER TABLE ONLY target_basketball.team DROP COLUMN IF EXISTS acronym;
-- ALTER TABLE ONLY target_basketball.team ADD COLUMN acronym text;

ALTER TABLE ONLY basketball.bb_series_post DROP CONSTRAINT IF EXISTS winner_league_equals_loser_league;

-- INSERT INTO target_basketball.team(name, acronym)
--   SELECT DISTINCT name, "tmID" acronym
--   FROM basketball.bb_teams
--   ORDER BY name;

INSERT INTO target_basketball.team(name)
  SELECT DISTINCT name
  FROM basketball.bb_teams
  ORDER BY name;


INSERT INTO target_basketball.league(name, sport, year)
  SELECT DISTINCT "lgID" "name", 'basketball', year
  FROM basketball.bb_teams
  ORDER BY year ASC, name ASC;
  -- UNION with other tables!

INSERT INTO target_basketball.team_league(team_id, league_id)
  SELECT DISTINCT tbb_team.team_id, tbb_league.league_id
  FROM basketball.bb_teams, target_basketball.team tbb_team, target_basketball.league tbb_league
  WHERE bb_teams.name = tbb_team.name
    AND bb_teams."lgID" = tbb_league.name
    AND bb_teams.year = tbb_league.year;

-- Assertion that matches are only between teams within one league
ALTER TABLE ONLY basketball.bb_series_post ADD CONSTRAINT winner_league_equals_loser_league CHECK ("lgIDWinner" = "lgIDLoser");

INSERT INTO target_basketball.match(league_id, team1, team2, date, points1, points2)
  SELECT DISTINCT tbb_league.league_id, 
                  winner.team_id, 
                  loser.team_id, 
                  to_date('01 Jan' || to_char(tbb_league.year, '9999') , 'DD Mon YYYY') date, 
                  bb_series_post."W", bb_series_post."L"
  FROM basketball.bb_series_post, 
       basketball.bb_teams bb_winner, 
       basketball.bb_teams bb_loser, 
       target_basketball.team winner, 
       target_basketball.team loser, 
       target_basketball.league tbb_league
  WHERE bb_series_post."tmIDWinner" = bb_winner."tmID"
    AND bb_winner.name = winner.name
    AND bb_series_post."tmIDLoser" = bb_loser."tmID"
    AND bb_loser.name = loser.name
    AND bb_series_post."lgIDWinner" = tbb_league.name
    AND bb_series_post."lgIDLoser" = tbb_league.name
    AND bb_winner."lgID" = tbb_league.name
    AND bb_loser."lgID" = tbb_league.name
    AND bb_series_post.year = tbb_league.year
  ORDER BY date ASC;
     -- TODO: 6 Matches are lost at this step

INSERT INTO target_basketball.location(city, state, country)
  SELECT DISTINCT *
  FROM (
    SELECT DISTINCT "birthCity" city, "birthState" state, "birthCountry" country
    FROM basketball.bb_master
    UNION
    SELECT DISTINCT "hsCity" city, "hsState" state, "hsCountry" country
    FROM basketball.bb_master
    ) a
  ORDER BY city;
  -- WHERE city != '' AND country != '';


ALTER TABLE ONLY target_basketball.person DROP COLUMN IF EXISTS bio_id;
ALTER TABLE ONLY target_basketball.person ADD COLUMN bio_id text;

INSERT INTO target_basketball.person(first_name, last_name, nick_name, birth_date, birth_location, death_date, death_location, weight, height, bio_id)
  SELECT "firstName" first_name, 
         "lastName" last_name, 
         "nameNick" nick_name, 
         to_date("birthDate", 'YYYY-MM-DD'), 
         birth_loc.location_id birth_location, 
         CASE "deathDate" WHEN '0000-00-00' THEN (null :: date)
              ELSE to_date("deathDate", 'YYYY-MM-DD')
         END,
         (null :: int),
         (weight :: real),
         (height :: real),
         "bioID"
  FROM basketball.bb_master, target_basketball.location birth_loc
  WHERE bb_master."birthCity" IS NOT DISTINCT FROM birth_loc.city
    AND bb_master."birthState" IS NOT DISTINCT FROM birth_loc.state
    AND bb_master."birthCountry" IS NOT DISTINCT FROM birth_loc.country
  ORDER BY last_name;

INSERT INTO target_basketball.school(name, location_id)
  SELECT DISTINCT name, location_id
  FROM (
    SELECT DISTINCT "highSchool" AS name, tbb_location.location_id AS location_id
    FROM basketball.bb_master, target_basketball.location tbb_location
    WHERE bb_master."hsCity" = tbb_location.city
      AND bb_master."hsState" = tbb_location.state
      AND bb_master."hsCountry" = tbb_location.country
    UNION
    SELECT DISTINCT bb_master.college AS name, (null :: int) AS location_id
    FROM basketball.bb_master
  ) a
  ORDER BY name;

INSERT INTO target_basketball.person_school(school_id, person_id)
  SELECT DISTINCT school_id, person_id
  FROM (
    SELECT school_id, person_id
    FROM target_basketball.school, basketball.bb_master, target_basketball.person
    WHERE school.name = bb_master.college
      AND person.bio_id = bb_master."bioID"
    UNION
    SELECT school_id, person_id
    FROM target_basketball.school, basketball.bb_master, target_basketball.person
    WHERE school.name = bb_master."highSchool"
      AND person.bio_id = bb_master."bioID"
  ) a;


INSERT INTO target_basketball.coaches(person_id, team_id, league_id)
  SELECT DISTINCT tbb_coaches.person_id, tbb_teams.team_id, tbb_teams.team_league_league_id
  FROM (
    SELECT *
      FROM(
        SELECT team_id, team_name, team_league_league_id, name AS league_name, year AS league_year
        FROM (
          SELECT team.team_id, team.name AS team_name, team_league.league_id AS team_league_league_id
          FROM target_basketball.team INNER JOIN target_basketball.team_league ON team.team_id = team_league.team_id
        ) tbb_team_team_league INNER JOIN target_basketball.league ON tbb_team_team_league.team_league_league_id = league.league_id
      ) tbb_team_league_joined INNER JOIN basketball.bb_teams ON tbb_team_league_joined.team_name = bb_teams.name 
                                                              AND tbb_team_league_joined.league_year = bb_teams.year
                                                              AND tbb_team_league_joined.league_name = bb_teams."lgID"
  ) tbb_teams, 
  ( SELECT *
    FROM basketball.bb_coaches INNER JOIN target_basketball.person ON bb_coaches."coachID" = person.bio_id
  ) tbb_coaches
  WHERE tbb_coaches."tmID" = tbb_teams."tmID" 
    AND tbb_coaches.year = tbb_teams.league_year
    AND tbb_coaches."lgID" = tbb_teams.league_name;

INSERT INTO target_basketball.plays_at(person_id, team_id, league_id)
  SELECT DISTINCT tbb_players.person_id, team_id, tbb_teams.team_league_league_id
  FROM (
    SELECT *
      FROM(
        SELECT team_id, team_name, team_league_league_id, name AS league_name, year AS league_year
        FROM (
          SELECT team.team_id, team.name AS team_name, team_league.league_id AS team_league_league_id
          FROM target_basketball.team INNER JOIN target_basketball.team_league ON team.team_id = team_league.team_id
        ) tbb_team_team_league INNER JOIN target_basketball.league ON tbb_team_team_league.team_league_league_id = league.league_id
      ) tbb_team_league_joined INNER JOIN basketball.bb_teams ON tbb_team_league_joined.team_name = bb_teams.name 
                                                              AND tbb_team_league_joined.league_year = bb_teams.year
                                                              AND tbb_team_league_joined.league_name = bb_teams."lgID"
  ) tbb_teams, 
  ( SELECT *
    FROM basketball.bb_draft INNER JOIN target_basketball.person ON bb_draft."playerID" = person.bio_id
  ) tbb_players
  WHERE tbb_players."tmID" = tbb_teams."tmID"
    AND tbb_players."draftYear" = tbb_teams.league_year
    AND tbb_players."lgID" = tbb_teams.league_name;
  -- TODO: Of 3814 with player ID only 3656 are inserted

INSERT INTO target_basketball.award(person_id, name, league_id)
  SELECT person_id, award, league_id
  FROM basketball.bb_awards_coaches, target_basketball.person, target_basketball.league
  WHERE bb_awards_coaches."coachID" = person.bio_id
    AND bb_awards_coaches.year = league.year
    AND bb_awards_coaches."lgID" = league.name;

INSERT INTO target_basketball.award(person_id, name, league_id)
  SELECT person_id, award, league_id
  FROM basketball.bb_awards_players, target_basketball.person, target_basketball.league
  WHERE bb_awards_players."playerID" = person.bio_id
    AND bb_awards_players.year = league.year
    AND bb_awards_players."lgID" = league.name;
  

ALTER TABLE ONLY target_basketball.person DROP COLUMN IF EXISTS bio_id;
