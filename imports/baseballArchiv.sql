INSERT INTO target_baseballarchiv.location(city, state, country)
  SELECT DISTINCT *
  FROM (
    SELECT DISTINCT city, state, country
    FROM baseballarchiv.schools
    UNION
    SELECT DISTINCT birthcity city, birthstate state, birthcountry country
    FROM baseballarchiv.master
    UNION
    SELECT DISTINCT deathcity city, deathstate state, deathcountry country
    FROM baseballarchiv.master) a
  WHERE city != '' AND country != '';

INSERT INTO target_baseballarchiv.school(name, location_id)
  SELECT DISTINCT schools.name_full "name", location.location_id
  FROM baseballarchiv.schools, target_baseballarchiv.location
  WHERE location.city = schools.city AND location.state = schools.state AND location.country = schools.country;

INSERT INTO target_baseballarchiv.person(first_name, last_name, nick_name, birth_date, birth_location, death_date, death_location, weight, height)
  SELECT
    namegiven first_name,
    namelast last_name,
    namefirst nick_name,
    DATE (birthyear || '-' || birthmonth || '-' || birthday) birth_date,
    birth_location.location_id birth_location,
    DATE (deathyear || '-' || deathmonth || '-' || deathday) death_date,
    death_location.location_id death_location,
    weight,
    height
  FROM baseballarchiv.master, target_baseballarchiv.location birth_location, target_baseballarchiv.location death_location
  WHERE
    birth_location.city = master.birthcity AND birth_location.state = master.birthstate AND birth_location.country = master.birthcountry AND
    death_location.city = master.deathcity AND death_location.state = master.deathstate AND death_location.country = master.deathcountry;

INSERT INTO target_baseballarchiv.person_school(person_id, school_id)
  SELECT DISTINCT
    person.person_id person_id,
    school.school_id school_id
  FROM
    target_baseballarchiv.person, target_baseballarchiv.school, target_baseballarchiv.location school_location,
    baseballarchiv.collegeplaying, baseballarchiv.master, baseballarchiv.schools
  WHERE
    person.first_name = master.namegiven AND person.last_name = master.namelast AND person.nick_name = master.namefirst AND
    school.name = schools.name_full AND school_location.city = schools.city AND school_location.location_id = school.location_id AND
    collegeplaying.playerid = master.playerid AND collegeplaying.schoolid = schools.schoolid;

INSERT INTO target_baseballarchiv.award(person_id, name)
  SELECT DISTINCT person.person_id person_id, ('Hall of fame ' || halloffame.yearid) "name"
  FROM baseballarchiv.master, target_baseballarchiv.person, baseballarchiv.halloffame
  WHERE
    person.first_name = master.namegiven AND person.last_name = master.namelast AND person.nick_name = master.namefirst AND
    halloffame.playerid = master.playerid;
