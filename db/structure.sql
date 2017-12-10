SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: btree_gin; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS btree_gin WITH SCHEMA public;


--
-- Name: EXTENSION btree_gin; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION btree_gin IS 'support for indexing common datatypes in GIN';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA public;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track execution statistics of all SQL statements executed';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: calendar_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE calendar_events (
    id character varying NOT NULL,
    user_id integer NOT NULL,
    company_id integer,
    notes_doc_link character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reported_invalid boolean
);


--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE cards (
    id bigint NOT NULL,
    trello_id character varying NOT NULL,
    archived boolean DEFAULT false NOT NULL,
    list_id bigint NOT NULL,
    company_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: cards_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE cards_id_seq OWNED BY cards.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE companies (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    domain character varying,
    crunchbase_id character varying,
    team_id integer,
    capital_raised bigint DEFAULT 0 NOT NULL,
    description text,
    industry character varying[],
    verified boolean DEFAULT false NOT NULL,
    "primary" boolean DEFAULT false NOT NULL,
    al_id integer,
    location character varying
);


--
-- Name: companies_founders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE companies_founders (
    company_id bigint NOT NULL,
    founder_id bigint NOT NULL
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE companies_id_seq OWNED BY companies.id;


--
-- Name: companies_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE companies_users (
    company_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: competitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE competitions (
    id bigint NOT NULL,
    a_id bigint NOT NULL,
    b_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: competitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE competitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE competitions_id_seq OWNED BY competitions.id;


--
-- Name: competitors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE competitors (
    id integer NOT NULL,
    name character varying,
    crunchbase_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    industry character varying[],
    fund_type character varying[],
    al_id integer,
    location character varying[],
    country character varying,
    photo character varying,
    hq character varying,
    twitter character varying,
    facebook character varying,
    domain character varying,
    al_url character varying
);


--
-- Name: competitors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE competitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE competitors_id_seq OWNED BY competitors.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE emails (
    id bigint NOT NULL,
    body text,
    sentiment_score double precision,
    sentiment_magnitude double precision,
    founder_id bigint NOT NULL,
    company_id bigint NOT NULL,
    investor_id bigint NOT NULL,
    direction integer NOT NULL,
    old_stage integer,
    new_stage integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    intro_request_id bigint,
    subject text,
    email_id character varying
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE emails_id_seq OWNED BY emails.id;


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE entities (
    id bigint NOT NULL,
    name character varying NOT NULL,
    category character varying DEFAULT 'OTHER'::character varying NOT NULL,
    wiki character varying,
    mid character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    person_entities_count integer DEFAULT 0 NOT NULL
);


--
-- Name: entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE entities_id_seq OWNED BY entities.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE events (
    id bigint NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    action character varying NOT NULL,
    arg1 character varying,
    arg2 character varying,
    arg3 character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE events_id_seq OWNED BY events.id;


--
-- Name: founders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE founders (
    id bigint NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying,
    facebook character varying,
    twitter character varying,
    linkedin character varying,
    homepage character varying,
    crunchbase_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    logged_in_at timestamp without time zone,
    ip_address inet,
    city character varying,
    time_zone character varying,
    bio text,
    response_time integer,
    photo character varying,
    access_token character varying,
    refresh_token character varying,
    history_id bigint
);


--
-- Name: founders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE founders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: founders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE founders_id_seq OWNED BY founders.id;


--
-- Name: import_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE import_tasks (
    id bigint NOT NULL,
    founder_id bigint NOT NULL,
    headers jsonb DEFAULT '"{}"'::jsonb,
    samples jsonb[] DEFAULT '{}'::jsonb[],
    complete boolean DEFAULT false NOT NULL,
    header_row character varying[],
    total integer,
    imported integer,
    error_message character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    errored integer[] DEFAULT '{}'::integer[],
    duplicates jsonb[] DEFAULT '{}'::jsonb[]
);


--
-- Name: import_tasks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE import_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE import_tasks_id_seq OWNED BY import_tasks.id;


--
-- Name: intro_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE intro_requests (
    id bigint NOT NULL,
    token character varying NOT NULL,
    accepted boolean,
    investor_id bigint NOT NULL,
    company_id bigint NOT NULL,
    founder_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    open_city character varying,
    open_country character varying,
    open_device_type integer,
    click_domains character varying[] DEFAULT '{}'::character varying[],
    pitch_deck character varying,
    reason character varying,
    opened_at timestamp without time zone,
    context text,
    target_investor_id bigint,
    preview_html text,
    pending boolean DEFAULT true NOT NULL
);


--
-- Name: intro_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE intro_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intro_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE intro_requests_id_seq OWNED BY intro_requests.id;


--
-- Name: investments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE investments (
    company_id integer NOT NULL,
    competitor_id integer NOT NULL,
    funded_at timestamp without time zone,
    id bigint NOT NULL,
    investor_id bigint,
    featured boolean DEFAULT false,
    funding_type character varying,
    series character varying,
    round_size bigint
);


--
-- Name: investments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE investments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE investments_id_seq OWNED BY investments.id;


--
-- Name: investors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE investors (
    id bigint NOT NULL,
    first_name character varying NOT NULL,
    last_name character varying NOT NULL,
    email character varying,
    crunchbase_id character varying,
    role character varying,
    competitor_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text,
    industry character varying[],
    featured boolean DEFAULT false NOT NULL,
    target_investors_count integer DEFAULT 0 NOT NULL,
    photo character varying,
    twitter character varying,
    linkedin character varying,
    facebook character varying,
    homepage character varying,
    location character varying,
    fund_type character varying[],
    al_id integer,
    opted_in boolean,
    gender integer DEFAULT 0 NOT NULL,
    university_id bigint,
    time_zone character varying,
    country character varying,
    al_url character varying,
    last_fetched timestamp without time zone
);


--
-- Name: investors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE investors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE investors_id_seq OWNED BY investors.id;


--
-- Name: knowledges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE knowledges (
    id integer NOT NULL,
    body text NOT NULL,
    user_id integer,
    ts character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    team_id integer NOT NULL
);


--
-- Name: knowledges_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE knowledges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE knowledges_id_seq OWNED BY knowledges.id;


--
-- Name: lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE lists (
    id integer NOT NULL,
    trello_id character varying NOT NULL,
    name character varying NOT NULL,
    pos double precision NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    trello_board_id character varying NOT NULL
);


--
-- Name: lists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE lists_id_seq OWNED BY lists.id;


--
-- Name: logged_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE logged_events (
    id integer NOT NULL,
    reason text NOT NULL,
    record_id integer NOT NULL,
    count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    data json DEFAULT '[]'::json NOT NULL
);


--
-- Name: logged_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE logged_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logged_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE logged_events_id_seq OWNED BY logged_events.id;


--
-- Name: models; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE models (
    id bigint NOT NULL,
    name character varying NOT NULL,
    version integer NOT NULL,
    data_generation bigint,
    model_generation bigint,
    last_trained timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    metrics hstore
);


--
-- Name: models_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE models_id_seq OWNED BY models.id;


--
-- Name: news; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE news (
    id bigint NOT NULL,
    investor_id bigint,
    company_id bigint,
    url character varying NOT NULL,
    title character varying NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    published_at timestamp without time zone,
    sentiment_score double precision,
    sentiment_magnitude double precision
);


--
-- Name: news_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE news_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE news_id_seq OWNED BY news.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE notes (
    id bigint NOT NULL,
    founder_id bigint NOT NULL,
    body text NOT NULL,
    subject_type character varying NOT NULL,
    subject_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE notes_id_seq OWNED BY notes.id;


--
-- Name: person_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE person_entities (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    person_type character varying NOT NULL,
    person_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    featured boolean DEFAULT false
);


--
-- Name: person_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE person_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: person_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE person_entities_id_seq OWNED BY person_entities.id;


--
-- Name: pitches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE pitches (
    id bigint NOT NULL,
    "when" timestamp without time zone NOT NULL,
    decision timestamp without time zone,
    deadline timestamp without time zone,
    funded boolean DEFAULT false NOT NULL,
    company_id bigint NOT NULL,
    snapshot character varying,
    prevote_doc character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    card_id bigint,
    quorum integer NOT NULL
);


--
-- Name: pitches_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pitches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pitches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pitches_id_seq OWNED BY pitches.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE posts (
    id bigint NOT NULL,
    investor_id bigint NOT NULL,
    url character varying NOT NULL,
    title character varying NOT NULL,
    published_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE posts_id_seq OWNED BY posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: target_investors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE target_investors (
    id bigint NOT NULL,
    investor_id bigint,
    founder_id bigint NOT NULL,
    stage integer DEFAULT 0 NOT NULL,
    last_response timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    note text,
    firm_name character varying,
    first_name character varying,
    last_name character varying,
    role character varying,
    industry character varying[],
    email character varying,
    fund_type character varying[],
    priority character varying,
    competitor_id bigint
);


--
-- Name: target_investors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE target_investors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: target_investors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE target_investors_id_seq OWNED BY target_investors.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE teams (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE teams_id_seq OWNED BY teams.id;


--
-- Name: tracking_pixels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tracking_pixels (
    id bigint NOT NULL,
    email_id bigint NOT NULL,
    token character varying NOT NULL,
    open_city character varying,
    open_country character varying,
    open_device_type integer,
    opened_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: tracking_pixels_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tracking_pixels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracking_pixels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tracking_pixels_id_seq OWNED BY tracking_pixels.id;


--
-- Name: tweeters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tweeters (
    id integer NOT NULL,
    username character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    owner_type character varying NOT NULL,
    owner_id bigint NOT NULL,
    private boolean DEFAULT false NOT NULL
);


--
-- Name: tweeters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tweeters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tweeters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tweeters_id_seq OWNED BY tweeters.id;


--
-- Name: tweets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE tweets (
    id integer NOT NULL,
    twitter_id bigint,
    tweeter_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    shared boolean DEFAULT false NOT NULL,
    tweeted_at timestamp without time zone,
    text character varying
);


--
-- Name: tweets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE tweets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tweets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE tweets_id_seq OWNED BY tweets.id;


--
-- Name: universities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE universities (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: universities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE universities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: universities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE universities_id_seq OWNED BY universities.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE users (
    id integer NOT NULL,
    username character varying NOT NULL,
    inactive_since timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    authentication_token character varying,
    trello_id character varying,
    slack_id character varying,
    cached_name character varying NOT NULL,
    team_id integer,
    access_token character varying,
    refresh_token character varying,
    logged_in_at timestamp without time zone DEFAULT '2017-03-02 19:56:21.793001'::timestamp without time zone NOT NULL,
    ip_address inet
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE votes (
    id integer NOT NULL,
    fit integer NOT NULL,
    team integer NOT NULL,
    product integer NOT NULL,
    market integer NOT NULL,
    overall integer,
    reason text,
    final boolean DEFAULT false NOT NULL,
    user_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    pitch_id bigint
);


--
-- Name: votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE votes_id_seq OWNED BY votes.id;


--
-- Name: cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards ALTER COLUMN id SET DEFAULT nextval('cards_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY companies ALTER COLUMN id SET DEFAULT nextval('companies_id_seq'::regclass);


--
-- Name: competitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY competitions ALTER COLUMN id SET DEFAULT nextval('competitions_id_seq'::regclass);


--
-- Name: competitors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY competitors ALTER COLUMN id SET DEFAULT nextval('competitors_id_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY emails ALTER COLUMN id SET DEFAULT nextval('emails_id_seq'::regclass);


--
-- Name: entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities ALTER COLUMN id SET DEFAULT nextval('entities_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN id SET DEFAULT nextval('events_id_seq'::regclass);


--
-- Name: founders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY founders ALTER COLUMN id SET DEFAULT nextval('founders_id_seq'::regclass);


--
-- Name: import_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY import_tasks ALTER COLUMN id SET DEFAULT nextval('import_tasks_id_seq'::regclass);


--
-- Name: intro_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY intro_requests ALTER COLUMN id SET DEFAULT nextval('intro_requests_id_seq'::regclass);


--
-- Name: investments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY investments ALTER COLUMN id SET DEFAULT nextval('investments_id_seq'::regclass);


--
-- Name: investors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY investors ALTER COLUMN id SET DEFAULT nextval('investors_id_seq'::regclass);


--
-- Name: knowledges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY knowledges ALTER COLUMN id SET DEFAULT nextval('knowledges_id_seq'::regclass);


--
-- Name: lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY lists ALTER COLUMN id SET DEFAULT nextval('lists_id_seq'::regclass);


--
-- Name: logged_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY logged_events ALTER COLUMN id SET DEFAULT nextval('logged_events_id_seq'::regclass);


--
-- Name: models id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY models ALTER COLUMN id SET DEFAULT nextval('models_id_seq'::regclass);


--
-- Name: news id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY news ALTER COLUMN id SET DEFAULT nextval('news_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY notes ALTER COLUMN id SET DEFAULT nextval('notes_id_seq'::regclass);


--
-- Name: person_entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY person_entities ALTER COLUMN id SET DEFAULT nextval('person_entities_id_seq'::regclass);


--
-- Name: pitches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pitches ALTER COLUMN id SET DEFAULT nextval('pitches_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts ALTER COLUMN id SET DEFAULT nextval('posts_id_seq'::regclass);


--
-- Name: target_investors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY target_investors ALTER COLUMN id SET DEFAULT nextval('target_investors_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams ALTER COLUMN id SET DEFAULT nextval('teams_id_seq'::regclass);


--
-- Name: tracking_pixels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tracking_pixels ALTER COLUMN id SET DEFAULT nextval('tracking_pixels_id_seq'::regclass);


--
-- Name: tweeters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tweeters ALTER COLUMN id SET DEFAULT nextval('tweeters_id_seq'::regclass);


--
-- Name: tweets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY tweets ALTER COLUMN id SET DEFAULT nextval('tweets_id_seq'::regclass);


--
-- Name: universities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY universities ALTER COLUMN id SET DEFAULT nextval('universities_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY votes ALTER COLUMN id SET DEFAULT nextval('votes_id_seq'::regclass);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: calendar_events calendar_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY calendar_events
    ADD CONSTRAINT calendar_events_pkey PRIMARY KEY (id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: competitions competitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY competitions
    ADD CONSTRAINT competitions_pkey PRIMARY KEY (id);


--
-- Name: competitors competitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY competitors
    ADD CONSTRAINT competitors_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: entities entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: founders founders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY founders
    ADD CONSTRAINT founders_pkey PRIMARY KEY (id);


--
-- Name: import_tasks import_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY import_tasks
    ADD CONSTRAINT import_tasks_pkey PRIMARY KEY (id);


--
-- Name: intro_requests intro_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY intro_requests
    ADD CONSTRAINT intro_requests_pkey PRIMARY KEY (id);


--
-- Name: investments investments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investments
    ADD CONSTRAINT investments_pkey PRIMARY KEY (id);


--
-- Name: investors investors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investors
    ADD CONSTRAINT investors_pkey PRIMARY KEY (id);


--
-- Name: knowledges knowledges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY knowledges
    ADD CONSTRAINT knowledges_pkey PRIMARY KEY (id);


--
-- Name: lists lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: logged_events logged_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY logged_events
    ADD CONSTRAINT logged_events_pkey PRIMARY KEY (id);


--
-- Name: models models_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY models
    ADD CONSTRAINT models_pkey PRIMARY KEY (id);


--
-- Name: news news_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: person_entities person_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY person_entities
    ADD CONSTRAINT person_entities_pkey PRIMARY KEY (id);


--
-- Name: pitches pitches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pitches
    ADD CONSTRAINT pitches_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: target_investors target_investors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY target_investors
    ADD CONSTRAINT target_investors_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: tracking_pixels tracking_pixels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tracking_pixels
    ADD CONSTRAINT tracking_pixels_pkey PRIMARY KEY (id);


--
-- Name: tweeters tweeters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tweeters
    ADD CONSTRAINT tweeters_pkey PRIMARY KEY (id);


--
-- Name: tweets tweets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tweets
    ADD CONSTRAINT tweets_pkey PRIMARY KEY (id);


--
-- Name: universities universities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY universities
    ADD CONSTRAINT universities_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: companies_name_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX companies_name_gin_trgm_idx ON companies USING gin (name gin_trgm_ops);


--
-- Name: companies_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX companies_to_tsvector_idx ON companies USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- Name: competitors_name_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX competitors_name_gin_trgm_idx ON competitors USING gin (name gin_trgm_ops);


--
-- Name: founders_city_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX founders_city_gin_trgm_idx ON founders USING gin (city gin_trgm_ops);


--
-- Name: index_calendar_events_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calendar_events_on_company_id ON calendar_events USING btree (company_id);


--
-- Name: index_calendar_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calendar_events_on_user_id ON calendar_events USING btree (user_id);


--
-- Name: index_cards_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cards_on_company_id ON cards USING btree (company_id);


--
-- Name: index_cards_on_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cards_on_list_id ON cards USING btree (list_id);


--
-- Name: index_cards_on_trello_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_cards_on_trello_id ON cards USING btree (trello_id);


--
-- Name: index_companies_founders_on_company_id_and_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_founders_on_company_id_and_founder_id ON companies_founders USING btree (company_id, founder_id);


--
-- Name: index_companies_founders_on_founder_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_founders_on_founder_id_and_company_id ON companies_founders USING btree (founder_id, company_id);


--
-- Name: index_companies_on_al_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_al_id ON companies USING btree (al_id);


--
-- Name: index_companies_on_crunchbase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_crunchbase_id ON companies USING btree (crunchbase_id);


--
-- Name: index_companies_on_domain; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_domain ON companies USING btree (domain);


--
-- Name: index_companies_on_industry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_industry ON companies USING gin (industry);


--
-- Name: index_companies_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_name ON companies USING btree (name);


--
-- Name: index_companies_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_team_id ON companies USING btree (team_id);


--
-- Name: index_companies_users_on_company_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_company_id_and_user_id ON companies_users USING btree (company_id, user_id);


--
-- Name: index_companies_users_on_user_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_user_id_and_company_id ON companies_users USING btree (user_id, company_id);


--
-- Name: index_competitions_on_a_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitions_on_a_id ON competitions USING btree (a_id);


--
-- Name: index_competitions_on_a_id_and_b_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitions_on_a_id_and_b_id ON competitions USING btree (a_id, b_id);


--
-- Name: index_competitions_on_b_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitions_on_b_id ON competitions USING btree (b_id);


--
-- Name: index_competitors_on_crunchbase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitors_on_crunchbase_id ON competitors USING btree (crunchbase_id);


--
-- Name: index_competitors_on_fund_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitors_on_fund_type ON competitors USING gin (fund_type);


--
-- Name: index_competitors_on_industry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitors_on_industry ON competitors USING gin (industry);


--
-- Name: index_competitors_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitors_on_location ON competitors USING gin (location);


--
-- Name: index_competitors_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitors_on_name ON competitors USING btree (name);


--
-- Name: index_emails_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_company_id ON emails USING btree (company_id);


--
-- Name: index_emails_on_email_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_emails_on_email_id ON emails USING btree (email_id);


--
-- Name: index_emails_on_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_founder_id ON emails USING btree (founder_id);


--
-- Name: index_emails_on_intro_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_intro_request_id ON emails USING btree (intro_request_id);


--
-- Name: index_emails_on_investor_founder_dir_ca; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_investor_founder_dir_ca ON emails USING gin (investor_id, founder_id, direction, created_at);


--
-- Name: index_emails_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_investor_id ON emails USING btree (investor_id);


--
-- Name: index_entities_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_name ON entities USING btree (name);


--
-- Name: index_events_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_subject_type_and_subject_id ON events USING btree (subject_type, subject_id);


--
-- Name: index_founders_on_crunchbase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_crunchbase_id ON founders USING btree (crunchbase_id);


--
-- Name: index_founders_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_email ON founders USING btree (email);


--
-- Name: index_founders_on_facebook; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_facebook ON founders USING btree (facebook);


--
-- Name: index_founders_on_homepage; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_homepage ON founders USING btree (homepage);


--
-- Name: index_founders_on_linkedin; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_linkedin ON founders USING btree (linkedin);


--
-- Name: index_founders_on_twitter; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_twitter ON founders USING btree (twitter);


--
-- Name: index_import_tasks_on_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_import_tasks_on_founder_id ON import_tasks USING btree (founder_id);


--
-- Name: index_intro_requests_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intro_requests_on_company_id ON intro_requests USING btree (company_id);


--
-- Name: index_intro_requests_on_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intro_requests_on_founder_id ON intro_requests USING btree (founder_id);


--
-- Name: index_intro_requests_on_investor_founder_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_intro_requests_on_investor_founder_and_company_id ON intro_requests USING btree (investor_id, founder_id, company_id);


--
-- Name: index_intro_requests_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intro_requests_on_investor_id ON intro_requests USING btree (investor_id);


--
-- Name: index_intro_requests_on_target_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intro_requests_on_target_investor_id ON intro_requests USING btree (target_investor_id);


--
-- Name: index_intro_requests_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_intro_requests_on_token ON intro_requests USING btree (token);


--
-- Name: index_investments_on_company_id_and_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investments_on_company_id_and_competitor_id ON investments USING btree (company_id, competitor_id);


--
-- Name: index_investments_on_competitor_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investments_on_competitor_id_and_company_id ON investments USING btree (competitor_id, company_id);


--
-- Name: index_investments_on_funded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investments_on_funded_at ON investments USING btree (funded_at);


--
-- Name: index_investments_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investments_on_investor_id ON investments USING btree (investor_id);


--
-- Name: index_investors_on_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_competitor_id ON investors USING btree (competitor_id);


--
-- Name: index_investors_on_crunchbase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_crunchbase_id ON investors USING btree (crunchbase_id);


--
-- Name: index_investors_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_email ON investors USING btree (email);


--
-- Name: index_investors_on_facebook; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_facebook ON investors USING btree (facebook);


--
-- Name: index_investors_on_first_name_and_last_name_and_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_first_name_and_last_name_and_competitor_id ON investors USING btree (first_name, last_name, competitor_id);


--
-- Name: index_investors_on_fund_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_fund_type ON investors USING gin (fund_type);


--
-- Name: index_investors_on_homepage; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_homepage ON investors USING btree (homepage);


--
-- Name: index_investors_on_industry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_industry ON investors USING gin (industry);


--
-- Name: index_investors_on_linkedin; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_linkedin ON investors USING btree (linkedin);


--
-- Name: index_investors_on_photo; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_photo ON investors USING btree (photo);


--
-- Name: index_investors_on_twitter; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_twitter ON investors USING btree (twitter);


--
-- Name: index_investors_on_university_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_university_id ON investors USING btree (university_id);


--
-- Name: index_knowledges_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledges_on_team_id ON knowledges USING btree (team_id);


--
-- Name: index_knowledges_on_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_knowledges_on_ts ON knowledges USING btree (ts);


--
-- Name: index_knowledges_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledges_on_user_id ON knowledges USING btree (user_id);


--
-- Name: index_lists_on_pos_and_trello_board_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lists_on_pos_and_trello_board_id ON lists USING btree (pos, trello_board_id);


--
-- Name: index_lists_on_trello_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lists_on_trello_id ON lists USING btree (trello_id);


--
-- Name: index_logged_events_on_reason_and_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_logged_events_on_reason_and_record_id ON logged_events USING btree (reason, record_id);


--
-- Name: index_news_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_on_company_id ON news USING btree (company_id);


--
-- Name: index_news_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_on_investor_id ON news USING btree (investor_id);


--
-- Name: index_news_on_url_and_investor_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_news_on_url_and_investor_id_and_company_id ON news USING btree (url, investor_id, company_id);


--
-- Name: index_notes_on_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_founder_id ON notes USING btree (founder_id);


--
-- Name: index_notes_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_subject_type_and_subject_id ON notes USING btree (subject_type, subject_id);


--
-- Name: index_person_entities_on_entity_and_person; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_person_entities_on_entity_and_person ON person_entities USING btree (entity_id, person_type, person_id);


--
-- Name: index_person_entities_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_person_entities_on_entity_id ON person_entities USING btree (entity_id);


--
-- Name: index_person_entities_on_person_type_and_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_person_entities_on_person_type_and_person_id ON person_entities USING btree (person_type, person_id);


--
-- Name: index_pitches_on_card_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pitches_on_card_id ON pitches USING btree (card_id);


--
-- Name: index_pitches_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pitches_on_company_id ON pitches USING btree (company_id);


--
-- Name: index_pitches_on_prevote_doc; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pitches_on_prevote_doc ON pitches USING btree (prevote_doc);


--
-- Name: index_pitches_on_snapshot; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pitches_on_snapshot ON pitches USING btree (snapshot);


--
-- Name: index_posts_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_investor_id ON posts USING btree (investor_id);


--
-- Name: index_target_investors_on_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_target_investors_on_competitor_id ON target_investors USING btree (competitor_id);


--
-- Name: index_target_investors_on_first_last_firm_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_target_investors_on_first_last_firm_name ON target_investors USING btree (first_name, last_name, firm_name, founder_id);


--
-- Name: index_target_investors_on_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_target_investors_on_founder_id ON target_investors USING btree (founder_id);


--
-- Name: index_target_investors_on_fund_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_target_investors_on_fund_type ON target_investors USING gin (fund_type);


--
-- Name: index_target_investors_on_industry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_target_investors_on_industry ON target_investors USING gin (industry);


--
-- Name: index_target_investors_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_target_investors_on_investor_id ON target_investors USING btree (investor_id);


--
-- Name: index_target_investors_on_investor_id_and_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_target_investors_on_investor_id_and_founder_id ON target_investors USING btree (investor_id, founder_id);


--
-- Name: index_teams_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_on_name ON teams USING btree (name);


--
-- Name: index_tracking_pixels_on_email_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tracking_pixels_on_email_id ON tracking_pixels USING btree (email_id);


--
-- Name: index_tracking_pixels_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tracking_pixels_on_token ON tracking_pixels USING btree (token);


--
-- Name: index_tweeters_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tweeters_on_owner_type_and_owner_id ON tweeters USING btree (owner_type, owner_id);


--
-- Name: index_tweeters_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tweeters_on_username ON tweeters USING btree (username);


--
-- Name: index_tweets_on_tweeter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tweets_on_tweeter_id ON tweets USING btree (tweeter_id);


--
-- Name: index_tweets_on_twitter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tweets_on_twitter_id ON tweets USING btree (twitter_id);


--
-- Name: index_users_on_cached_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_cached_name ON users USING btree (cached_name);


--
-- Name: index_users_on_slack_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_slack_id ON users USING btree (slack_id);


--
-- Name: index_users_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_team_id ON users USING btree (team_id);


--
-- Name: index_users_on_trello_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_trello_id ON users USING btree (trello_id);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON users USING btree (username);


--
-- Name: index_votes_on_pitch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_pitch_id ON votes USING btree (pitch_id);


--
-- Name: index_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_user_id ON votes USING btree (user_id);


--
-- Name: investors_first_name_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX investors_first_name_gin_trgm_idx ON investors USING gin (first_name gin_trgm_ops);


--
-- Name: investors_last_name_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX investors_last_name_gin_trgm_idx ON investors USING gin (last_name gin_trgm_ops);


--
-- Name: investors_location_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX investors_location_gin_trgm_idx ON investors USING gin (location gin_trgm_ops);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: emails fk_rails_041ca7bd32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT fk_rails_041ca7bd32 FOREIGN KEY (company_id) REFERENCES companies(id);


--
-- Name: intro_requests fk_rails_0c534c3fde; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY intro_requests
    ADD CONSTRAINT fk_rails_0c534c3fde FOREIGN KEY (target_investor_id) REFERENCES target_investors(id);


--
-- Name: competitions fk_rails_10c7683510; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY competitions
    ADD CONSTRAINT fk_rails_10c7683510 FOREIGN KEY (a_id) REFERENCES companies(id);


--
-- Name: pitches fk_rails_115ef0c2b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pitches
    ADD CONSTRAINT fk_rails_115ef0c2b5 FOREIGN KEY (card_id) REFERENCES cards(id);


--
-- Name: cards fk_rails_11b32bc490; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT fk_rails_11b32bc490 FOREIGN KEY (list_id) REFERENCES lists(id);


--
-- Name: import_tasks fk_rails_1705f4b9e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY import_tasks
    ADD CONSTRAINT fk_rails_1705f4b9e0 FOREIGN KEY (founder_id) REFERENCES founders(id);


--
-- Name: intro_requests fk_rails_203146869d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY intro_requests
    ADD CONSTRAINT fk_rails_203146869d FOREIGN KEY (investor_id) REFERENCES investors(id);


--
-- Name: knowledges fk_rails_26ba4c0c3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY knowledges
    ADD CONSTRAINT fk_rails_26ba4c0c3e FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: posts fk_rails_285bce5540; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY posts
    ADD CONSTRAINT fk_rails_285bce5540 FOREIGN KEY (investor_id) REFERENCES investors(id);


--
-- Name: competitions fk_rails_297510c89c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY competitions
    ADD CONSTRAINT fk_rails_297510c89c FOREIGN KEY (b_id) REFERENCES companies(id);


--
-- Name: cards fk_rails_31e9cb1159; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY cards
    ADD CONSTRAINT fk_rails_31e9cb1159 FOREIGN KEY (company_id) REFERENCES companies(id);


--
-- Name: emails fk_rails_4f7e384dec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT fk_rails_4f7e384dec FOREIGN KEY (intro_request_id) REFERENCES intro_requests(id);


--
-- Name: tracking_pixels fk_rails_586fbe02f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY tracking_pixels
    ADD CONSTRAINT fk_rails_586fbe02f8 FOREIGN KEY (email_id) REFERENCES emails(id);


--
-- Name: investors fk_rails_5e5b9710a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investors
    ADD CONSTRAINT fk_rails_5e5b9710a2 FOREIGN KEY (university_id) REFERENCES universities(id);


--
-- Name: emails fk_rails_602d137517; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT fk_rails_602d137517 FOREIGN KEY (investor_id) REFERENCES investors(id);


--
-- Name: news fk_rails_646d2bd38d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY news
    ADD CONSTRAINT fk_rails_646d2bd38d FOREIGN KEY (investor_id) REFERENCES investors(id);


--
-- Name: person_entities fk_rails_6d42d0b8bf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY person_entities
    ADD CONSTRAINT fk_rails_6d42d0b8bf FOREIGN KEY (entity_id) REFERENCES entities(id);


--
-- Name: votes fk_rails_8455b71b47; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT fk_rails_8455b71b47 FOREIGN KEY (pitch_id) REFERENCES pitches(id);


--
-- Name: pitches fk_rails_87434cc962; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pitches
    ADD CONSTRAINT fk_rails_87434cc962 FOREIGN KEY (company_id) REFERENCES companies(id);


--
-- Name: calendar_events fk_rails_930e3c0bf4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY calendar_events
    ADD CONSTRAINT fk_rails_930e3c0bf4 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: target_investors fk_rails_9cfe54f56c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY target_investors
    ADD CONSTRAINT fk_rails_9cfe54f56c FOREIGN KEY (founder_id) REFERENCES founders(id);


--
-- Name: users fk_rails_b2bbf87303; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY users
    ADD CONSTRAINT fk_rails_b2bbf87303 FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: intro_requests fk_rails_b2d35a8529; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY intro_requests
    ADD CONSTRAINT fk_rails_b2d35a8529 FOREIGN KEY (company_id) REFERENCES companies(id);


--
-- Name: investors fk_rails_bfbc7d2c7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investors
    ADD CONSTRAINT fk_rails_bfbc7d2c7a FOREIGN KEY (competitor_id) REFERENCES competitors(id);


--
-- Name: calendar_events fk_rails_c3e3b9423b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY calendar_events
    ADD CONSTRAINT fk_rails_c3e3b9423b FOREIGN KEY (company_id) REFERENCES companies(id);


--
-- Name: target_investors fk_rails_c8ec711f83; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY target_investors
    ADD CONSTRAINT fk_rails_c8ec711f83 FOREIGN KEY (competitor_id) REFERENCES competitors(id);


--
-- Name: votes fk_rails_c9b3bef597; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY votes
    ADD CONSTRAINT fk_rails_c9b3bef597 FOREIGN KEY (user_id) REFERENCES users(id);


--
-- Name: notes fk_rails_d6c54b7443; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY notes
    ADD CONSTRAINT fk_rails_d6c54b7443 FOREIGN KEY (founder_id) REFERENCES founders(id);


--
-- Name: knowledges fk_rails_d823280e2d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY knowledges
    ADD CONSTRAINT fk_rails_d823280e2d FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: intro_requests fk_rails_d87bff6194; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY intro_requests
    ADD CONSTRAINT fk_rails_d87bff6194 FOREIGN KEY (founder_id) REFERENCES founders(id);


--
-- Name: news fk_rails_ddd1ba457d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY news
    ADD CONSTRAINT fk_rails_ddd1ba457d FOREIGN KEY (company_id) REFERENCES companies(id);


--
-- Name: investments fk_rails_e0aa7acb5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY investments
    ADD CONSTRAINT fk_rails_e0aa7acb5f FOREIGN KEY (investor_id) REFERENCES investors(id);


--
-- Name: emails fk_rails_f6176d396e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY emails
    ADD CONSTRAINT fk_rails_f6176d396e FOREIGN KEY (founder_id) REFERENCES founders(id);


--
-- Name: companies fk_rails_f7f30b55b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY companies
    ADD CONSTRAINT fk_rails_f7f30b55b8 FOREIGN KEY (team_id) REFERENCES teams(id);


--
-- Name: target_investors fk_rails_fb3356619c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY target_investors
    ADD CONSTRAINT fk_rails_fb3356619c FOREIGN KEY (investor_id) REFERENCES investors(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20160522185118'),
('20160522185352'),
('20160522185943'),
('20160526081845'),
('20160607172710'),
('20160608201717'),
('20160611011833'),
('20160612002622'),
('20160702165000'),
('20160731015127'),
('20160801004622'),
('20160801014143'),
('20160801014311'),
('20160801014943'),
('20160801040510'),
('20160803030126'),
('20160821125016'),
('20160821130511'),
('20160821164703'),
('20160821164830'),
('20160821164913'),
('20160821171537'),
('20160821220809'),
('20160829195559'),
('20160906100605'),
('20160918171101'),
('20161003052505'),
('20161026173909'),
('20161026173950'),
('20161026174157'),
('20161108050658'),
('20170126001559'),
('20170127224357'),
('20170205191411'),
('20170308064137'),
('20170308093754'),
('20170309215857'),
('20170323194208'),
('20170411084205'),
('20170630223110'),
('20170630223241'),
('20170630231539'),
('20170630231716'),
('20170704234730'),
('20170706161341'),
('20170706161549'),
('20170706161925'),
('20170706234719'),
('20170706234933'),
('20170706235543'),
('20170707212815'),
('20170710172847'),
('20170711003932'),
('20170711005418'),
('20170711011506'),
('20170711055253'),
('20170711150217'),
('20170711150233'),
('20170711150248'),
('20170711151022'),
('20170711151046'),
('20170711151109'),
('20170713220452'),
('20170717171806'),
('20170717172041'),
('20170717172105'),
('20170717221430'),
('20170718000911'),
('20170718195620'),
('20170719000608'),
('20170719000721'),
('20170719001734'),
('20170719191548'),
('20170719205903'),
('20170720015921'),
('20170721125920'),
('20170721205154'),
('20170724232031'),
('20170803085715'),
('20170814215715'),
('20170814222403'),
('20170814224808'),
('20170817093023'),
('20170831223533'),
('20170831235358'),
('20170901002805'),
('20170901011132'),
('20170901013410'),
('20170901222323'),
('20170902232836'),
('20170905202435'),
('20170905203536'),
('20170905205048'),
('20170906224155'),
('20170906230733'),
('20170907002704'),
('20170907011330'),
('20170907013240'),
('20170907020331'),
('20170907082031'),
('20170907082851'),
('20170907191659'),
('20170908001751'),
('20170908001828'),
('20170908014807'),
('20170908061548'),
('20170908062006'),
('20170909004347'),
('20170910052629'),
('20170911231243'),
('20170911231340'),
('20170912003929'),
('20170912004754'),
('20170912004910'),
('20170912004918'),
('20170912072307'),
('20170912074351'),
('20170912081157'),
('20170912082106'),
('20170912215956'),
('20170912222800'),
('20170912231818'),
('20170913005350'),
('20170913011915'),
('20170913023846'),
('20170913023856'),
('20170913203704'),
('20170914183606'),
('20170914184723'),
('20170915191458'),
('20170915235927'),
('20170919043157'),
('20170919091817'),
('20170925203126'),
('20170930070824'),
('20170930070911'),
('20171002023544'),
('20171006234544'),
('20171009204716'),
('20171010012458'),
('20171013124510'),
('20171016193127'),
('20171017065951'),
('20171017073841'),
('20171017114659'),
('20171020212520'),
('20171023230210'),
('20171030065046'),
('20171030181615'),
('20171107012911'),
('20171107111143'),
('20171108005014'),
('20171110185838'),
('20171119082029'),
('20171120001408'),
('20171121023523'),
('20171121095936'),
('20171122211959'),
('20171123002740'),
('20171123005005'),
('20171204091614'),
('20171204092443'),
('20171206074352'),
('20171206103132'),
('20171207112536'),
('20171209084559'),
('20171210093034');


