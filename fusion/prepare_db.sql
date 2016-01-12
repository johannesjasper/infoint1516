ALTER TABLE target_merged.plays_at
    DROP CONSTRAINT plays_at_team_id_fkey;
ALTER TABLE target_merged.plays_at
    ADD CONSTRAINT plays_at_team_id_fkey FOREIGN KEY (team_id, league_id) REFERENCES target_merged.team_league(team_id, league_id) ON UPDATE CASCADE;

ALTER TABLE target_merged.coaches
    DROP CONSTRAINT coaches_team_id_fkey;
ALTER TABLE target_merged.coaches
    ADD CONSTRAINT coaches_team_id_fkey FOREIGN KEY (team_id, league_id) REFERENCES target_merged.team_league(team_id, league_id) ON UPDATE CASCADE;

ALTER TABLE target_merged.person_school
    DROP CONSTRAINT person_school_school_id_fkey;
ALTER TABLE target_merged.person_school
    ADD CONSTRAINT person_school_school_id_fkey FOREIGN KEY (school_id) REFERENCES target_merged.school(school_id) ON UPDATE CASCADE ON DELETE CASCADE;