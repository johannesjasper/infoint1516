ALTER TABLE target_hockey.team ADD src_id VARCHAR(10);
ALTER TABLE target_hockey.person ADD src_player_id VARCHAR(10);
ALTER TABLE target_hockey.person ADD src_coach_id VARCHAR(10);


DELETE FROM target_hockey.award CASCADE;
DELETE FROM target_hockey.coaches CASCADE;
DELETE FROM target_hockey.plays_at CASCADE;
DELETE FROM target_hockey.team_league CASCADE;
DELETE FROM target_hockey.person CASCADE;
DELETE FROM target_hockey.team CASCADE;
DELETE FROM target_hockey.league CASCADE;
DELETE FROM target_hockey.location CASCADE;


-- teams
INSERT INTO target_hockey.team(name, src_id)
  SELECT DISTINCT name, teamid
  FROM hockey.team;

-- leagues
INSERT INTO target_hockey.league(year, name, sport)
  SELECT DISTINCT t.year, (t."leagueId"||'-'||s.stint), 'hockey'
  FROM hockey.team t
  JOIN hockey.scoring s ON t."leagueId"=s."leagueId" AND t.year=s.year;

-- team leagues
INSERT INTO target_hockey.team_league
  SELECT DISTINCT t.team_id, l.league_id
  FROM target_hockey.team t
  JOIN hockey.team src_t ON t.src_id=src_t.teamid
  JOIN hockey.scoring s ON src_t."leagueId"=s."leagueId" AND src_t.year=s.year AND src_t.teamid=s.teamid
  JOIN target_hockey.league l ON (src_t."leagueId"||'-'||s.stint)=l.name AND src_t.year=l.year;


-- locations
INSERT INTO target_hockey.location(city, state, country)
  SELECT DISTINCT m."birthCity", m."birthState", m."birthCountry"
  FROM hockey.master m
  WHERE m."birthCountry" IS NOT NULL;

-- persons
INSERT INTO target_hockey.person(first_name, last_name, nick_name, birth_date, birth_location, death_date, death_location, weight, height, src_player_id, src_coach_id)
  SELECT
    CASE WHEN "nameGiven" IS NULL THEN "firstName" ELSE split_part("nameGiven", ' ', 1) END AS firstname,
    "lastName",
    "nameNick",
    DATE ("birthYear"||'-'||"birthMon"||'-'||"birthDay") birth_date,
    bl.location_id birth_location,
    DATE ("deathYear"||'-'||"deathMon"||'-'||"deathDay") death_date,
    dl.location_id death_location,
    weight,
    height,
    playerid,
    coachid
  FROM hockey.master
  JOIN target_hockey.location bl ON "birthCity"=bl.city AND "birthState"=bl.state AND "birthCountry"=bl.country
  JOIN target_hockey.location dl ON "deathCity"=dl.city AND "deathState"=dl.state AND "deathCountry"=dl.country;

-- coaches
INSERT INTO target_hockey.coaches
  SELECT DISTINCT p.person_id, t.team_id, tl.league_id
  FROM target_hockey.person p
  JOIN hockey.coaches c ON p.src_coach_id=c.coachid
  JOIN target_hockey.team t ON t.src_id=c.teamid
  JOIN target_hockey.team_league tl ON t.team_id=tl.team_id
  JOIN target_hockey.league l ON tl.league_id=l.league_id AND c.year=l.year;

-- plays_at
INSERT INTO target_hockey.plays_at
  SELECT DISTINCT p.person_id, t.team_id, tl.league_id
  FROM target_hockey.person p
  JOIN hockey.scoring s ON p.src_player_id=s.playerid
  JOIN target_hockey.team t ON t.src_id=s.teamid
  JOIN target_hockey.team_league tl ON t.team_id=tl.team_id
  JOIN target_hockey.league l ON tl.league_id=l.league_id AND s.year=l.year;

-- award
INSERT INTO target_hockey.award(person_id, name, league_id)
  SELECT DISTINCT p.person_id, ca.award, l.league_id
  FROM hockey.coachaward ca
  JOIN target_hockey.person p ON p.src_coach_id=ca.coachid
  JOIN target_hockey.coaches c ON c.person_id=p.person_id
  JOIN target_hockey.league l ON l.league_id=c.league_id AND l.year=ca.year;

ALTER TABLE target_hockey.team DROP COLUMN src_id;
ALTER TABLE target_hockey.person DROP COLUMN src_player_id;
ALTER TABLE target_hockey.person DROP COLUMN src_coach_id;
