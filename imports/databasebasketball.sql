DELETE FROM target_databasebasketball.plays_at CASCADE;
DELETE FROM target_databasebasketball.person CASCADE;
DELETE FROM target_databasebasketball.team_league CASCADE;
DELETE FROM target_databasebasketball.team CASCADE;
DELETE FROM target_databasebasketball.league CASCADE;


-- league
INSERT INTO target_databasebasketball.league(name, sport, year) 
  SELECT DISTINCT
  CASE WHEN A.league='N' THEN 'NBA' 
    WHEN A.league='A' THEN 'ABA'
  END,
  'basketball',
  A.year
FROM 
  ((SELECT DISTINCT YEAR,LEAGUE FROM databasebasketball.dbb_player_regular_season order by year) 
    UNION
  (SELECT DISTINCT YEAR,LEAGUE FROM databasebasketball.dbb_player_playoffs order by year)) A;


-- team
INSERT INTO target_databasebasketball.team(name)
  SELECT DISTINCT location || ' ' || name
  FROM databasebasketball.dbb_team
  WHERE name != '';


-- person
INSERT INTO target_databasebasketball.person(first_name, last_name, birth_date, weight, height)
  SELECT DISTINCT
    firstname,
    lastname,
    birthdate,
    weight,
    (h_feet * 12)+h_inches
  FROM databasebasketball.dbb_player;


-- team_league
INSERT INTO target_databasebasketball.team_league(team_id, league_id)
  SELECT DISTINCT
    target_team.team_id,
    target_league.league_id
  FROM
    (SELECT ilkid, team, year, case league when 'A' then 'ABA' WHEN 'N' then 'NBA' END "league"
     FROM databasebasketball.dbb_player_regular_season) src_season,
    databasebasketball.dbb_team src_team,
    target_databasebasketball.team target_team,
    target_databasebasketball.league target_league
  WHERE
    src_season.team=src_team.team AND
    (src_team.location || ' ' || src_team.name)=target_team.name AND --> team_id
    src_season.year=target_league.year AND --> league_id
    src_season.league=target_league.name AND
    target_league.sport='basketball';


-- plays_at
INSERT INTO target_databasebasketball.plays_at(person_id, team_id, league_id)
  SELECT DISTINCT
    target_person.person_id,
    target_team.team_id,
    target_league.league_id
  FROM
    (SELECT ilkid, team, year, case league when 'A' then 'ABA' WHEN 'N' then 'NBA' END "league"
     FROM databasebasketball.dbb_player_regular_season) src_season,
    databasebasketball.dbb_team src_team,
    databasebasketball.dbb_player src_player,
    target_databasebasketball.team target_team,
    target_databasebasketball.person target_person,
    target_databasebasketball.league target_league
  WHERE
    src_season.team=src_team.team AND
    src_season.ilkid=src_player.ilkid AND
    (src_team.location || ' ' || src_team.name)=target_team.name AND --> team_id
    src_player.firstname=target_person.first_name AND -->person_id
    src_player.lastname=target_person.last_name AND
    src_player.birthdate=target_person.birth_date AND
    src_player.weight=target_person.weight AND
    target_person.height=((src_player.h_feet * 12)+src_player.h_inches) AND
    src_season.year=target_league.year AND --> league_id
    src_season.league=target_league.name AND
    target_league.sport='basketball'
