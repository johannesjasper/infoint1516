SET search_path TO target_merged;

SELECT *
FROM (
	-- wins per player
	SELECT L.sport, L.name, PA.person_id, COUNT(*) AS wins
	FROM (
		-- wins per league and team
		SELECT league_id,
		CASE WHEN M.points1 > M.points2 THEN team1 ELSE team2 END AS team_id
		FROM match M
	) WT
	JOIN league L ON L.league_id = WT.league_id
	JOIN plays_at PA ON PA.league_id = WT.league_id AND PA.team_id = WT.team_id
	GROUP BY L.sport, L.name, PA.person_id
) WP
JOIN person P ON WP.person_id = P.person_id
ORDER BY WP.sport, wins DESC

