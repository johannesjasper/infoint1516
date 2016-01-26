SELECT (weight * 0.453592 / POWER(height * 0.0254, 2)) as bmi, *
FROM target_merged.person 
WHERE 
  weight IS NOT NULL AND 
  height IS NOT NULL AND 
  height > 0 AND 
  weight > 0

-- BMI by sport
SELECT l.sport, AVG(p.bmi), AVG(p.weight), AVG(p.height)
FROM 
  (
    SELECT (weight * 0.453592 / POWER(height * 0.0254, 2)) as bmi, *
    FROM target_merged.person 
    WHERE 
      weight IS NOT NULL AND 
      height IS NOT NULL AND 
      height > 0 AND 
      weight > 0
  ) p, 
  target_merged.plays_at pa, 
  target_merged.league l
WHERE p.person_id = pa.person_id AND pa.league_id = l.league_id
GROUP BY l.sport

-- BMI by birth city
SELECT l.state, AVG(p.bmi) as bmi_avg
FROM 
  (
    SELECT (weight * 0.453592 / POWER(height * 0.0254, 2)) as bmi, *
    FROM target_merged.person 
    WHERE 
      weight IS NOT NULL AND 
      height IS NOT NULL AND 
      height > 0 AND 
      weight > 0
  ) p, 
  target_merged.location l 
WHERE 
  p.birth_location = l.location_id AND
  l.country = 'USA'
GROUP BY l.state
ORDER BY bmi_avg DESC

-- BMI by school city
SELECT s.name, l.city, l.state, AVG(p.bmi) as bmi_avg
FROM 
  (
    SELECT (weight * 0.453592 / POWER(height * 0.0254, 2)) as bmi, *
    FROM target_merged.person 
    WHERE 
      weight IS NOT NULL AND 
      height IS NOT NULL AND 
      height > 0 AND 
      weight > 0
  ) p, 
  target_merged.person_school ps, 
  target_merged.school s, 
  target_merged.location l 
WHERE 
  p.person_id = ps.person_id AND 
  ps.school_id = s.school_id AND 
  s.location_id = l.location_id AND
  l.country = 'USA'
GROUP BY s.school_id, l.location_id
ORDER BY bmi_avg DESC

-- BMI by school state
SELECT SUBSTRING(l.state, 0, 3) as state_short, AVG(p.bmi) as bmi_avg
FROM 
  (
    SELECT (weight * 0.453592 / POWER(height * 0.0254, 2)) as bmi, *
    FROM target_merged.person 
    WHERE 
      weight IS NOT NULL AND 
      height IS NOT NULL AND 
      height > 0 AND 
      weight > 0
  ) p, 
  target_merged.person_school ps, 
  target_merged.school s, 
  target_merged.location l 
WHERE 
  p.person_id = ps.person_id AND 
  ps.school_id = s.school_id AND 
  s.location_id = l.location_id AND
  l.country = 'USA'
GROUP BY state_short
ORDER BY bmi_avg DESC
