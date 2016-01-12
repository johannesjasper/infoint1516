ALTER TABLE target_merged.plays_at
    DROP CONSTRAINT plays_at_team_id_fkey;
ALTER TABLE target_merged.plays_at
    ADD CONSTRAINT plays_at_team_id_fkey FOREIGN KEY (team_id, league_id) REFERENCES target_merged.team_league(team_id, league_id) ON UPDATE CASCADE;

ALTER TABLE target_merged.coaches
    DROP CONSTRAINT coaches_team_id_fkey;
ALTER TABLE target_merged.coaches
    ADD CONSTRAINT coaches_team_id_fkey FOREIGN KEY (team_id, league_id) REFERENCES target_merged.team_league(team_id, league_id) ON UPDATE CASCADE;
