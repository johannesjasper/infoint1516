TRUNCATE target_wm2014.league CASCADE;
TRUNCATE target_wm2014.team CASCADE;
TRUNCATE target_wm2014.team_league CASCADE;
TRUNCATE target_wm2014.person CASCADE;
TRUNCATE target_wm2014.plays_at CASCADE;

-- league
INSERT INTO target_wm2014.league(year, name, sport) VALUES(2014, 'World Championship', 'football');

-- teams
-- national teams
INSERT INTO target_wm2014.team(name)
  SELECT DISTINCT "Name"
  FROM wm2014.club;
-- international teams
INSERT INTO target_wm2014.team(name)
  SELECT "Name"
  FROM wm2014.teamsoccer;

-- team leagues
INSERT INTO target_wm2014.team_league
  SELECT team_id, league_id
  FROM target_wm2014.team, target_wm2014.league; -- there is only one

-- players
INSERT INTO target_wm2014.person(first_name, last_name, birth_date)
  SELECT "Vorname", "Nachname", "Geburtstag"
  FROM wm2014.spieler;

-- plays at
INSERT INTO target_wm2014.plays_at
  SELECT p.person_id, t.team_id, l.league_id
  FROM
    target_wm2014.person p,
    wm2014.spieler src_p,
    target_wm2014.league l, -- there is only one
    target_wm2014.team t,
    wm2014.club src_t

  WHERE p.first_name = src_p."Vorname"
  AND p.last_name = src_p."Nachname"
  AND p.birth_date = src_p."Geburtstag"
  AND t.name = src_t."Name"
  AND src_p."ClubId" = src_t.id;

INSERT INTO target_wm2014.plays_at
  SELECT p.person_id, t.team_id, l.league_id
  FROM
    target_wm2014.person p,
    wm2014.spieler src_p,
    target_wm2014.league l,
    target_wm2014.team t,
    wm2014.teamsoccer src_t

  WHERE p.first_name = src_p."Vorname"
  AND p.last_name = src_p."Nachname"
  AND p.birth_date = src_p."Geburtstag"
  AND t.name = src_t."Name"
  AND src_p."TeamId" = src_t.id;
