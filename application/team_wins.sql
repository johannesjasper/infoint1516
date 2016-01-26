-- which team won most games in what league?

SELECT sport, name, COUNT(team_id) AS wins, league_name FROM (
SELECT 
  CASE 
    WHEN M.points1 > M.points2 THEN T1.team_id
    WHEN M.points1 < M.points2 THEN T2.team_id
    ELSE NULL
  END AS team_id,
  CASE 
    WHEN M.points1 > M.points2 THEN T1.name
    WHEN M.points1 < M.points2 THEN T2.name
    ELSE NULL
  END AS name,
  L.sport AS sport,
  L.name as league_name
  FROM target_merged.Match M
  JOIN target_merged.Team T1 ON M.team1 = T1.team_id
  JOIN target_merged.Team T2 ON M.team2 = T2.team_id
  JOIN target_merged.league L ON M.league_id = L.league_id

  order by name
) W  
GROUP BY sport, team_id, name, league_name
ORDER BY sport, wins DESC