DELETE FROM target_football.plays_at CASCADE;
DELETE FROM target_football.person CASCADE;
DELETE FROM target_football.team_league CASCADE;
DELETE FROM target_football.team CASCADE;
DELETE FROM target_football.league CASCADE;

-- league
INSERT INTO target_football.league(name, sport, year)
	SELECT DISTINCT
		caption,
		'soccer',
		year
	FROM
		football.seasons;

-- team
INSERT INTO target_football.team(name)
	SELECT DISTINCT name
	FROM 
		football.teams;


-- team_league
INSERT INTO target_football.team_league(team_id,league_id)
	SELECT DISTINCT
		target_team.team_id,
		target_league.league_id
	FROM
		football.teamstoseasons ts,
		football.teams t,
		football.seasons s,
		target_football.league target_league,
		target_football.team target_team
	WHERE
		ts.seasonid=s.id AND
		ts.teamid = t.id AND
		target_league.year=s.year AND
		target_league.name=s.caption AND
		target_league.sport='soccer' AND
		target_team.name=t.name;


-- person
INSERT INTO target_football.person(first_name, last_name, birth_date)
	SELECT
		A[1] "first_name",
		A[2] "last_name",
		TO_DATE(dateofbirth,'YYYY-MM-DD')
	FROM	
		(SELECT
			regexp_split_to_array(name,' '),
			dateofbirth
		FROM
			football.players
		WHERE
			name similar to '\w* \w*') as dt(A);


-- plays_at
INSERT INTO target_football.plays_at(person_id,team_id,league_id)
	SELECT 
		target_person.person_id,
		target_team.team_id,
		target_league.league_id
	FROM
		football.players src_player,
		football.teamstoplayers src_teamplayer,
		football.teams src_team,
		football.teamstoseasons src_teamseason,
		football.seasons src_season,
		target_football.person target_person, 
		target_football.team target_team,
		target_football.league target_league
	WHERE
		src_player.id=src_teamplayer.playerid AND
		src_teamplayer.teamid=src_team.id AND
		src_team.id=src_teamseason.teamid AND
		src_teamseason.seasonid=src_season.id AND
		src_player.name=(target_person.first_name||' '||target_person.last_name) AND
		src_team.name=target_team.name AND
		src_season.caption=target_league.name;

	












