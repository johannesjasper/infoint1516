DELETE FROM target.award;
DELETE FROM target.coaches;
DELETE FROM target.plays_at;
DELETE FROM target.match;
DELETE FROM target.team_league;
DELETE FROM target.team;
DELETE FROM target.league;
DELETE FROM target.person_school;
DELETE FROM target.school;
DELETE FROM target.person;
DELETE FROM target.location;

ALTER SEQUENCE target.award_award_id_seq RESTART WITH 1;
ALTER SEQUENCE target.league_league_id_seq RESTART WITH 1;
ALTER SEQUENCE target.location_location_id_seq RESTART WITH 1;
ALTER SEQUENCE target.match_match_id_seq RESTART WITH 1;
ALTER SEQUENCE target.person_person_id_seq RESTART WITH 1;
ALTER SEQUENCE target.school_school_id_seq RESTART WITH 1;
ALTER SEQUENCE target.team_team_id_seq RESTART WITH 1;

-- INITIAL COPY INTO TARGET SCHEMA
-- use target_basketball as initial target

INSERT INTO target.location(city, state, country)
	SELECT city, state, country FROM target_basketball.location;

INSERT INTO target.team(name)
	SELECT name FROM target_basketball.team;

INSERT INTO target.league(year,name,sport)
	SELECT year, name, sport FROM target_basketball.league;

INSERT INTO target.person(first_name,last_name,nick_name,birth_date,birth_location,death_date,death_location,weight,height)
	SELECT first_name,last_name,nick_name,birth_date,birth_location,death_date,death_location,weight,height from target_basketball.person;

INSERT INTO target.school(name, location_id)
	SELECT name, location_id FROM target_basketball.school;

INSERT INTO target.person_school(person_id,school_id)
	SELECT person_id,school_id FROM target_basketball.person_school;

INSERT INTO target.team_league(team_id,league_id)
	SELECT team_id,league_id FROM target_basketball.team_league;

INSERT INTO target.coaches(person_id, team_id, league_id)
	SELECT person_id, team_id, league_id FROM target_basketball.coaches;

INSERT INTO target.award(person_id, name, league_id)
	SELECT person_id, name, league_id FROM target_basketball.award;

INSERT INTO target.match(league_id, team1, team2, date, points1, points2)
	SELECT league_id, team1, team2, date, points1, points2 FROM target_basketball.match;

INSERT INTO target.plays_at(person_id, team_id, league_id)
	SELECT person_id, team_id, league_id FROM target_basketball.plays_at;

