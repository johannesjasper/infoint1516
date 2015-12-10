-- TODO: use loop to insert from all schemas


-- 1: LEAGUE VALUES OF ALL SCHEMAS
INSERT INTO target.league(year, name, sport)
	SELECT
		year,
		name,
		sport
	FROM
		target_baseballarchiv.league src
	WHERE
		NOT EXISTS(
			SELECT *
			FROM target.league t
			WHERE
				t.year=src.year AND
				t.name=src.name AND
				t.sport=src.sport
			);


-- 2: TEAM VALUES OF ALL SCHEMAS
INSERT INTO target.team(name)
	SELECT
		name
	FROM
		target_baseballarchiv.team src
	WHERE
		NOT EXISTS(
			SELECT t.name
			FROM target.team t
			WHERE
				t.name=src.name
			);


-- 3: LOCATION VALUES OF ALL SCHEMAS
INSERT INTO target.location(city, state, country)
	SELECT
		city, state, country
	FROM
		target_baseballarchiv.location src
	WHERE
		NOT EXISTS(
			SELECT 
			FROM target.location t
			WHERE
				t.city=src.city AND
				t.state=src.state AND
				t.country=src.country
			);


-- 4: PERSON VALUES OF ALL SCHEMAS (collect location foreign keys from target)
INSERT INTO target.person(
	first_name,
	last_name,
	nick_name,
	birth_date,
	birth_location,
	death_date,
	death_location,
	weight,
	height)
SELECT
	first_name,
	last_name,
	nick_name,
	birth_date,
	CASE WHEN birth_location IS NULL THEN NULL ELSE target_birth_location_id END "birth_location", 
	death_date,
	CASE WHEN death_location IS NULL THEN NULL ELSE target_death_location_id END "death_location",
	weight,
	height 
FROM 
	(SELECT
		first_name,
		last_name,
		nick_name,
		birth_date,
		birth_location,
		(SELECT location_id
			FROM target.location loc
			WHERE loc.city IS NOT DISTINCT FROM location_birth.city
				AND loc.state IS NOT DISTINCT FROM location_birth.state
				AND loc.country IS NOT DISTINCT FROM location_birth.country)
		"target_birth_location_id",
		death_date,
		death_location,
		(SELECT location_id
		FROM target.location loc
		WHERE loc.city IS NOT DISTINCT FROM location_death.city
			AND loc.state IS NOT DISTINCT FROM location_death.state
			AND loc.country IS NOT DISTINCT FROM location_death.country)
		"target_death_location_id",
		weight,
		height
	FROM
		target_baseballarchiv.person p
		LEFT OUTER JOIN target_baseballarchiv.location location_birth
			ON p.birth_location = location_birth.location_id
		LEFT OUTER JOIN target_baseballarchiv.location location_death
			ON p.death_location=location_death.location_id
	) A;

-- 5: School
INSERT INTO target.school(name,location_id)
	SELECT
		SRC.name,
		SRC.location_id
	FROM	
		(SELECT
			name,
			(SELECT location_id
				FROM target.location loc
				WHERE loc.city IS NOT DISTINCT FROM school_location.city
					AND loc.state IS NOT DISTINCT FROM school_location.state
					AND loc.country IS NOT DISTINCT FROM school_location.country)
			 "location_id"
		FROM
			target_baseballarchiv.school src_school
			LEFT OUTER JOIN target_baseballarchiv.location school_location
				ON src_school.location_id = school_location.location_id
		) SRC
	WHERE 
		NOT EXISTS (
			SELECT name, location_id
			FROM target.school target_school
			WHERE
				target_school.name=SRC.name AND
				target_school.location_id=SRC.location_id
		);

-- 6: PersonSchool
-- INSERT INTO target.person_school(person_id,school_id)


-- SELECT
-- 	*
-- FROM
-- 	target_baseballarchiv.person_school src
-- 	JOIN target_baseballarchiv.person src_person
-- 		ON src.person_id=src_person.person_id
-- WHERE




-- 7: Match
-- 8: Coaches
-- 9: Award
-- 10: TeamLeague
-- 11: Plays_at








