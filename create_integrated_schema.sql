--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = target, pg_catalog;

DROP TABLE target.team_league CASCADE;
DROP TABLE target.school CASCADE;
DROP TABLE target.plays_at CASCADE;
DROP TABLE target.person_school CASCADE;
DROP TABLE target.person CASCADE;
DROP TABLE target.match CASCADE;
DROP TABLE target.location CASCADE;
DROP TABLE target.coaches CASCADE;
DROP TABLE target.award CASCADE;
DROP TABLE target.league CASCADE;
DROP TABLE target.team CASCADE;

DROP EXTENSION plpgsql;
DROP SCHEMA target;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA target;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA target IS 'target schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = target, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: league; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE league (
    league_id SERIAL UNIQUE,
    year integer,
    name text,
    sport text,
    PRIMARY KEY (league_id)
);


--
-- Name: team; Type: TABLE; Schema: public; Owner: -; Tablespace:
--


CREATE TABLE team (
    team_id SERIAL UNIQUE,
    name text,
    PRIMARY KEY (team_id)
);


--
-- Name: location; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE location (
    location_id SERIAL UNIQUE,
    city text,
    state text,
    country text,
    PRIMARY KEY (location_id)
);

--
-- Name: school; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE school (
    school_id SERIAL UNIQUE,
    name text,
    location_id integer,
    PRIMARY KEY (school_id),
    FOREIGN KEY (location_id) REFERENCES location (location_id)
);

--
-- Name: person; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE person (
    person_id SERIAL UNIQUE,
    first_name text,
    last_name text,
    nick_name text,
    birth_date date,
    birth_location integer,
    death_date date,
    death_location integer,
    weight real,
    height real,
    PRIMARY KEY (person_id),
    FOREIGN KEY (birth_location) REFERENCES location (location_id),
    FOREIGN KEY (death_location) REFERENCES location (location_id)
);

--
-- Name: award; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE award (
    award_id SERIAL UNIQUE,
    person_id integer NOT NULL,
    name text NOT NULL,
    league_id integer,
    PRIMARY KEY (award_id),
    FOREIGN KEY (person_id) REFERENCES person (person_id),
    FOREIGN KEY (league_id) REFERENCES league (league_id)
);


--
-- Name: team_league; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE team_league (
    team_id integer NOT NULL,
    league_id integer NOT NULL,
    PRIMARY KEY (team_id, league_id),
    FOREIGN KEY (team_id) REFERENCES team (team_id),
    FOREIGN KEY (league_id) REFERENCES league (league_id)
);


--
-- Name: coaches; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE coaches (
    person_id integer NOT NULL,
    team_id integer NOT NULL,
    league_id integer NOT NULL,
    PRIMARY KEY (person_id, team_id, league_id),
    FOREIGN KEY (person_id) REFERENCES person (person_id),
    FOREIGN KEY (team_id, league_id) REFERENCES team_league (team_id, league_id)
);



--
-- Name: match; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE match (
    match_id SERIAL UNIQUE,
    league_id integer,
    team1 integer,
    team2 integer,
    date date,
    points1 integer,
    points2 integer,
    PRIMARY KEY (match_id),
    FOREIGN KEY (team1) REFERENCES team (team_id),
    FOREIGN KEY (team2) REFERENCES team (team_id),
    FOREIGN KEY (league_id) REFERENCES league (league_id)
);




--
-- Name: person_school; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE person_school (
    person_id integer NOT NULL,
    school_id integer NOT NULL,
    PRIMARY KEY (person_id, school_id),
    FOREIGN KEY (person_id) REFERENCES person (person_id),
    FOREIGN KEY (school_id) REFERENCES school (school_id)
);


--
-- Name: plays_at; Type: TABLE; Schema: public; Owner: -; Tablespace:
--

CREATE TABLE plays_at (
    person_id integer NOT NULL,
    team_id integer NOT NULL,
    league_id integer NOT NULL,
    PRIMARY KEY (person_id, team_id, league_id),
    FOREIGN KEY (person_id) REFERENCES person (person_id),
    FOREIGN KEY (team_id, league_id) REFERENCES team_league (team_id, league_id)
);


--
-- Data for Name: award; Type: TABLE DATA; Schema: public; Owner: -
--

COPY award (award_id, person_id, name, league_id) FROM stdin;
\.


--
-- Data for Name: coaches; Type: TABLE DATA; Schema: public; Owner: -
--

COPY coaches (person_id, team_id, league_id) FROM stdin;
\.


--
-- Data for Name: location; Type: TABLE DATA; Schema: public; Owner: -
--

COPY location (location_id, city, state, country) FROM stdin;
\.


--
-- Data for Name: match; Type: TABLE DATA; Schema: public; Owner: -
--

COPY match (match_id, league_id, team1, team2, date, points1, points2) FROM stdin;
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: -
--

COPY person (person_id, first_name, last_name, nick_name, birth_date, birth_location, death_date, death_location, weight, height) FROM stdin;
\.


--
-- Data for Name: person_school; Type: TABLE DATA; Schema: public; Owner: -
--

COPY person_school (person_id, school_id) FROM stdin;
\.


--
-- Data for Name: plays_at; Type: TABLE DATA; Schema: public; Owner: -
--

COPY plays_at (person_id, team_id, league_id) FROM stdin;
\.


--
-- Data for Name: school; Type: TABLE DATA; Schema: public; Owner: -
--

COPY school (school_id, name, location_id) FROM stdin;
\.


--
-- Data for Name: team_season; Type: TABLE DATA; Schema: public; Owner: -
--

COPY team_league (team_id, league_id) FROM stdin;
\.


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA target FROM PUBLIC;
GRANT ALL ON SCHEMA target TO PUBLIC;


--
-- PostgreSQL database dump complete
--
