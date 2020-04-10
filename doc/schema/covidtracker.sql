--
-- PostgreSQL database dump
--

-- Dumped from database version 11.7
-- Dumped by pg_dump version 11.7

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    phone character varying(100),
    national_id character varying(200),
    deviceid character varying(100),
    age integer,
    gender character varying(20),
    state character varying(20),
    name character varying(200),
    email character varying(200),
    id integer NOT NULL
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: person_contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person_contacts (
    first_time timestamp without time zone,
    last_time timestamp without time zone,
    initial_latitude character varying(100),
    initial_longitude character varying(100),
    last_latitude character varying(100),
    last_longitude character varying(100),
    id integer NOT NULL,
    from_deviceid character varying(20),
    to_deviceid character varying(20)
);


ALTER TABLE public.person_contacts OWNER TO postgres;

--
-- Name: person_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_contacts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_contacts_id_seq OWNER TO postgres;

--
-- Name: person_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.person_contacts_id_seq OWNED BY public.person_contacts.id;


--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_id_seq OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.person_id_seq OWNED BY public.person.id;


--
-- Name: person id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT nextval('public.person_id_seq'::regclass);


--
-- Name: person_contacts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person_contacts ALTER COLUMN id SET DEFAULT nextval('public.person_contacts_id_seq'::regclass);


--
-- Name: person_contacts person_contacts_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person_contacts
    ADD CONSTRAINT person_contacts_id_key UNIQUE (id);


--
-- Name: person person_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_id_key UNIQUE (id);


--
-- PostgreSQL database dump complete
--

