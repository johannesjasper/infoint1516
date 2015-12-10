DELETE FROM target_basketball201112.plays_at CASCADE;
DELETE FROM target_basketball201112.person CASCADE;
DELETE FROM target_basketball201112.team_league CASCADE;
DELETE FROM target_basketball201112.team CASCADE;
DELETE FROM target_basketball201112.league CASCADE;

INSERT INTO target_basketball201112.league(name, sport, year) 
  VALUES('NBA', 'basketball', 2011);

INSERT INTO target_basketball201112.team(name)
  SELECT DISTINCT teamname "name"
  FROM basketball201112.team;

INSERT INTO target_basketball201112.team_league(team_id, league_id)
  SELECT target_team.team_id, league.league_id
  FROM basketball201112.team src_team, target_basketball201112.team target_team, target_basketball201112.league
  WHERE
    league.name = 'NBA' AND
    src_team.teamname = target_team.name;

INSERT INTO target_basketball201112.person(first_name, last_name)
  SELECT DISTINCT
    split_part(player.playertruename, ', ', 1) first_name,
    split_part(player.playertruename, ', ', 2) last_name
  FROM basketball201112.player;


INSERT INTO target_basketball201112.plays_at(person_id, team_id, league_id)
  SELECT DISTINCT
    person.person_id person_id,
    team.team_id team_id,
    league.league_id league_id
  FROM
    basketball201112.player, 
    target_basketball201112.person, target_basketball201112.team , target_basketball201112.league
  WHERE
    player.playertruename = (person.first_name || ', ' || person.last_name) AND
    player.teamname = team.name AND
    league.name = 'NBA';

