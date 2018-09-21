SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
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


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: calendar_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendar_events (
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

CREATE TABLE public.cards (
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

CREATE SEQUENCE public.cards_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cards_id_seq OWNED BY public.cards.id;


--
-- Name: companies; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies (
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
    location character varying,
    acquisition_date date,
    ipo_date date,
    ipo_valuation bigint,
    stage integer DEFAULT 0
);


--
-- Name: companies_founders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies_founders (
    company_id bigint NOT NULL,
    founder_id bigint NOT NULL
);


--
-- Name: companies_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.companies_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: companies_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.companies_id_seq OWNED BY public.companies.id;


--
-- Name: companies_users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.companies_users (
    company_id integer NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: competitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competitions (
    id bigint NOT NULL,
    a_id bigint NOT NULL,
    b_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: competitions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competitions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competitions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competitions_id_seq OWNED BY public.competitions.id;


--
-- Name: competitors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.competitors (
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
    al_url character varying,
    verified boolean DEFAULT false NOT NULL
);


--
-- Name: investors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.investors (
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
    last_fetched timestamp without time zone,
    verified boolean DEFAULT false NOT NULL,
    token character varying,
    average_response_time integer,
    hidden boolean DEFAULT false NOT NULL,
    review public.hstore
);


--
-- Name: competitor_investor_aggs; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.competitor_investor_aggs AS
 SELECT competitors.id AS competitor_id,
    COALESCE(sum(investors.target_investors_count), (0)::bigint) AS target_count,
    bool_or(COALESCE(investors.featured, false)) AS featured,
    bool_or(COALESCE(investors.verified, false)) AS verified
   FROM (public.competitors
     JOIN public.investors ON ((investors.competitor_id = competitors.id)))
  GROUP BY competitors.id
  WITH NO DATA;


--
-- Name: investments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.investments (
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
-- Name: competitor_velocities; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.competitor_velocities AS
 SELECT competitors.id AS competitor_id,
    count(investments.id) AS velocity
   FROM (public.competitors
     JOIN public.investments ON ((investments.competitor_id = competitors.id)))
  WHERE (investments.funded_at > (now() - '1 year'::interval))
  GROUP BY competitors.id
  WITH NO DATA;


--
-- Name: competitors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.competitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: competitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.competitors_id_seq OWNED BY public.competitors.id;


--
-- Name: emails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.emails (
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
    email_id character varying,
    bulk boolean DEFAULT false NOT NULL
);


--
-- Name: emails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.emails_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: emails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.emails_id_seq OWNED BY public.emails.id;


--
-- Name: entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.entities (
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

CREATE SEQUENCE public.entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.entities_id_seq OWNED BY public.entities.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.events (
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

CREATE SEQUENCE public.events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: founders; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.founders (
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
    history_id bigint,
    unsubscribed boolean DEFAULT false NOT NULL,
    token character varying,
    affiliated_exits integer,
    cb_id character varying
);


--
-- Name: founders_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.founders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: founders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.founders_id_seq OWNED BY public.founders.id;


--
-- Name: import_tasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.import_tasks (
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

CREATE SEQUENCE public.import_tasks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: import_tasks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.import_tasks_id_seq OWNED BY public.import_tasks.id;


--
-- Name: intro_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.intro_requests (
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

CREATE SEQUENCE public.intro_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intro_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.intro_requests_id_seq OWNED BY public.intro_requests.id;


--
-- Name: investments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.investments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.investments_id_seq OWNED BY public.investments.id;


--
-- Name: person_entities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.person_entities (
    id bigint NOT NULL,
    entity_id bigint NOT NULL,
    person_type character varying NOT NULL,
    person_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    featured boolean DEFAULT false,
    count integer DEFAULT 1 NOT NULL
);


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id bigint NOT NULL,
    investor_id bigint NOT NULL,
    url character varying NOT NULL,
    title character varying NOT NULL,
    published_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    description text
);


--
-- Name: investor_entities; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.investor_entities AS
 SELECT competitors.id AS competitor_id,
    investors.id AS investor_id,
    entities.id AS entity_id,
    (COALESCE(max(investor_person_entities.count), 0) + COALESCE(max(post_person_entities.count), 0)) AS count
   FROM (((((public.investors
     LEFT JOIN public.posts ON ((posts.investor_id = investors.id)))
     LEFT JOIN public.person_entities investor_person_entities ON ((((investor_person_entities.person_type)::text = 'Investor'::text) AND (investor_person_entities.person_id = investors.id))))
     LEFT JOIN public.person_entities post_person_entities ON ((((post_person_entities.person_type)::text = 'Post'::text) AND (post_person_entities.person_id = posts.id))))
     JOIN public.entities ON (((investor_person_entities.entity_id = entities.id) OR (post_person_entities.entity_id = entities.id))))
     JOIN public.competitors ON ((competitors.id = investors.competitor_id)))
  GROUP BY competitors.id, investors.id, entities.id
  WITH NO DATA;


--
-- Name: investors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.investors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: investors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.investors_id_seq OWNED BY public.investors.id;


--
-- Name: knowledges; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.knowledges (
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

CREATE SEQUENCE public.knowledges_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: knowledges_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.knowledges_id_seq OWNED BY public.knowledges.id;


--
-- Name: lists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lists (
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

CREATE SEQUENCE public.lists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: lists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.lists_id_seq OWNED BY public.lists.id;


--
-- Name: logged_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.logged_events (
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

CREATE SEQUENCE public.logged_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: logged_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.logged_events_id_seq OWNED BY public.logged_events.id;


--
-- Name: models; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.models (
    id bigint NOT NULL,
    name character varying NOT NULL,
    version integer NOT NULL,
    data_generation bigint,
    model_generation bigint,
    last_trained timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    metrics public.hstore
);


--
-- Name: models_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.models_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: models_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.models_id_seq OWNED BY public.models.id;


--
-- Name: news; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news (
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

CREATE SEQUENCE public.news_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_id_seq OWNED BY public.news.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
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

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: person_entities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.person_entities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: person_entities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.person_entities_id_seq OWNED BY public.person_entities.id;


--
-- Name: pitches; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pitches (
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

CREATE SEQUENCE public.pitches_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pitches_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pitches_id_seq OWNED BY public.pitches.id;


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: target_investors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.target_investors (
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

CREATE SEQUENCE public.target_investors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: target_investors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.target_investors_id_seq OWNED BY public.target_investors.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.teams_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: tracking_pixels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tracking_pixels (
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

CREATE SEQUENCE public.tracking_pixels_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tracking_pixels_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tracking_pixels_id_seq OWNED BY public.tracking_pixels.id;


--
-- Name: tweeters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tweeters (
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

CREATE SEQUENCE public.tweeters_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tweeters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tweeters_id_seq OWNED BY public.tweeters.id;


--
-- Name: tweets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tweets (
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

CREATE SEQUENCE public.tweets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tweets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tweets_id_seq OWNED BY public.tweets.id;


--
-- Name: universities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.universities (
    id bigint NOT NULL,
    name character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: universities_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.universities_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: universities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.universities_id_seq OWNED BY public.universities.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
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
    ip_address inet,
    admin boolean DEFAULT false
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.votes (
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

CREATE SEQUENCE public.votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.votes_id_seq OWNED BY public.votes.id;


--
-- Name: cards id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards ALTER COLUMN id SET DEFAULT nextval('public.cards_id_seq'::regclass);


--
-- Name: companies id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies ALTER COLUMN id SET DEFAULT nextval('public.companies_id_seq'::regclass);


--
-- Name: competitions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitions ALTER COLUMN id SET DEFAULT nextval('public.competitions_id_seq'::regclass);


--
-- Name: competitors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitors ALTER COLUMN id SET DEFAULT nextval('public.competitors_id_seq'::regclass);


--
-- Name: emails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails ALTER COLUMN id SET DEFAULT nextval('public.emails_id_seq'::regclass);


--
-- Name: entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities ALTER COLUMN id SET DEFAULT nextval('public.entities_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: founders id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founders ALTER COLUMN id SET DEFAULT nextval('public.founders_id_seq'::regclass);


--
-- Name: import_tasks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_tasks ALTER COLUMN id SET DEFAULT nextval('public.import_tasks_id_seq'::regclass);


--
-- Name: intro_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intro_requests ALTER COLUMN id SET DEFAULT nextval('public.intro_requests_id_seq'::regclass);


--
-- Name: investments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.investments ALTER COLUMN id SET DEFAULT nextval('public.investments_id_seq'::regclass);


--
-- Name: investors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.investors ALTER COLUMN id SET DEFAULT nextval('public.investors_id_seq'::regclass);


--
-- Name: knowledges id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledges ALTER COLUMN id SET DEFAULT nextval('public.knowledges_id_seq'::regclass);


--
-- Name: lists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lists ALTER COLUMN id SET DEFAULT nextval('public.lists_id_seq'::regclass);


--
-- Name: logged_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logged_events ALTER COLUMN id SET DEFAULT nextval('public.logged_events_id_seq'::regclass);


--
-- Name: models id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models ALTER COLUMN id SET DEFAULT nextval('public.models_id_seq'::regclass);


--
-- Name: news id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news ALTER COLUMN id SET DEFAULT nextval('public.news_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: person_entities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_entities ALTER COLUMN id SET DEFAULT nextval('public.person_entities_id_seq'::regclass);


--
-- Name: pitches id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pitches ALTER COLUMN id SET DEFAULT nextval('public.pitches_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: target_investors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.target_investors ALTER COLUMN id SET DEFAULT nextval('public.target_investors_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: tracking_pixels id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracking_pixels ALTER COLUMN id SET DEFAULT nextval('public.tracking_pixels_id_seq'::regclass);


--
-- Name: tweeters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tweeters ALTER COLUMN id SET DEFAULT nextval('public.tweeters_id_seq'::regclass);


--
-- Name: tweets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tweets ALTER COLUMN id SET DEFAULT nextval('public.tweets_id_seq'::regclass);


--
-- Name: universities id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universities ALTER COLUMN id SET DEFAULT nextval('public.universities_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes ALTER COLUMN id SET DEFAULT nextval('public.votes_id_seq'::regclass);


--
-- Name: competitors competitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitors
    ADD CONSTRAINT competitors_pkey PRIMARY KEY (id);


--
-- Name: competitor_coinvestors; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.competitor_coinvestors AS
 SELECT competitors.id AS competitor_id,
    coinvestors_join.coi_arr AS coinvestors
   FROM (public.competitors
     LEFT JOIN LATERAL ( WITH comp_companies AS (
                 SELECT companies.id
                   FROM (public.companies
                     JOIN public.investments ON ((investments.company_id = companies.id)))
                  WHERE (investments.competitor_id = competitors.id)
                ), comp_coinvestors AS (
                 SELECT coinvestors.id,
                    coinvestors.name,
                    count(investments.id) AS overlap
                   FROM ((public.investments
                     JOIN comp_companies ON ((comp_companies.id = investments.company_id)))
                     JOIN public.competitors coinvestors ON ((coinvestors.id = investments.competitor_id)))
                  WHERE (coinvestors.id <> competitors.id)
                  GROUP BY coinvestors.id
                  ORDER BY (count(investments.id)) DESC
                 LIMIT 5
                )
         SELECT array_to_json(array_agg(comp_coinvestors.*)) AS coi_arr
           FROM comp_coinvestors) coinvestors_join ON (true))
  WITH NO DATA;


--
-- Name: investors investors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.investors
    ADD CONSTRAINT investors_pkey PRIMARY KEY (id);


--
-- Name: competitor_partners; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.competitor_partners AS
 SELECT competitors.id AS competitor_id,
    partners_join.partners_arr AS partners
   FROM (public.competitors
     LEFT JOIN LATERAL ( WITH partners_results AS (
                 SELECT investors.id,
                    investors.role,
                    investors.verified
                   FROM public.investors
                  WHERE ((investors.competitor_id = competitors.id) AND (investors.hidden = false))
                ), filtered_partners_results AS (
                 SELECT partners_results.id
                   FROM partners_results
                  WHERE ((lower((partners_results.role)::text) ~~* ANY (ARRAY['%managing%'::text, '%partner%'::text, '%director%'::text, '%associate%'::text, '%principal%'::text, '%ceo%'::text, '%founder%'::text, '%invest%'::text])) OR (partners_results.verified = true))
                ), all_ids AS (
                 SELECT filtered_partners_results.id
                   FROM filtered_partners_results
                UNION
                 SELECT partners_results.id
                   FROM partners_results
                  WHERE (NOT (EXISTS ( SELECT filtered_partners_results.id
                           FROM filtered_partners_results)))
                ), all_partners AS (
                 SELECT investors.id,
                    investors.first_name,
                    investors.last_name,
                    investors.photo,
                    investors.role,
                    investors.verified
                   FROM ((public.investors
                     JOIN all_ids ON ((investors.id = all_ids.id)))
                     LEFT JOIN public.investments ON ((investments.investor_id = investors.id)))
                  GROUP BY investors.id
                  ORDER BY investors.featured DESC, investors.verified DESC, (max(investments.funded_at)) DESC NULLS LAST, (count(investments.id)) DESC
                 LIMIT 25
                )
         SELECT array_to_json(array_agg(all_partners.*)) AS partners_arr
           FROM all_partners) partners_join ON (true))
  WITH NO DATA;


--
-- Name: companies companies_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT companies_pkey PRIMARY KEY (id);


--
-- Name: competitor_recent_investments; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.competitor_recent_investments AS
 SELECT competitors.id AS competitor_id,
    recent_investments_join.ri_arr AS recent_investments
   FROM (public.competitors
     LEFT JOIN LATERAL ( WITH recent_investments AS (
                 SELECT companies.id,
                    companies.name,
                    companies.domain,
                    companies.crunchbase_id
                   FROM (public.companies
                     JOIN public.investments ON ((investments.company_id = companies.id)))
                  WHERE (investments.competitor_id = competitors.id)
                  GROUP BY companies.id
                  ORDER BY (max(investments.funded_at)) DESC NULLS LAST, (count(NULLIF(investments.featured, false))) DESC, companies.capital_raised DESC, (count(investments.id)) DESC
                 LIMIT 5
                )
         SELECT array_to_json(array_agg(recent_investments.*)) AS ri_arr
           FROM recent_investments) recent_investments_join ON (true))
  WITH NO DATA;


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: calendar_events calendar_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT calendar_events_pkey PRIMARY KEY (id);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (id);


--
-- Name: competitions competitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitions
    ADD CONSTRAINT competitions_pkey PRIMARY KEY (id);


--
-- Name: emails emails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT emails_pkey PRIMARY KEY (id);


--
-- Name: entities entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.entities
    ADD CONSTRAINT entities_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: founders founders_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.founders
    ADD CONSTRAINT founders_pkey PRIMARY KEY (id);


--
-- Name: import_tasks import_tasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_tasks
    ADD CONSTRAINT import_tasks_pkey PRIMARY KEY (id);


--
-- Name: intro_requests intro_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intro_requests
    ADD CONSTRAINT intro_requests_pkey PRIMARY KEY (id);


--
-- Name: investments investments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.investments
    ADD CONSTRAINT investments_pkey PRIMARY KEY (id);


--
-- Name: knowledges knowledges_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledges
    ADD CONSTRAINT knowledges_pkey PRIMARY KEY (id);


--
-- Name: lists lists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lists
    ADD CONSTRAINT lists_pkey PRIMARY KEY (id);


--
-- Name: logged_events logged_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.logged_events
    ADD CONSTRAINT logged_events_pkey PRIMARY KEY (id);


--
-- Name: models models_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.models
    ADD CONSTRAINT models_pkey PRIMARY KEY (id);


--
-- Name: news news_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT news_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: person_entities person_entities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_entities
    ADD CONSTRAINT person_entities_pkey PRIMARY KEY (id);


--
-- Name: pitches pitches_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pitches
    ADD CONSTRAINT pitches_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: target_investors target_investors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.target_investors
    ADD CONSTRAINT target_investors_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: tracking_pixels tracking_pixels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracking_pixels
    ADD CONSTRAINT tracking_pixels_pkey PRIMARY KEY (id);


--
-- Name: tweeters tweeters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tweeters
    ADD CONSTRAINT tweeters_pkey PRIMARY KEY (id);


--
-- Name: tweets tweets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tweets
    ADD CONSTRAINT tweets_pkey PRIMARY KEY (id);


--
-- Name: universities universities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.universities
    ADD CONSTRAINT universities_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: votes votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT votes_pkey PRIMARY KEY (id);


--
-- Name: companies_name_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX companies_name_gin_trgm_idx ON public.companies USING gin (name public.gin_trgm_ops);


--
-- Name: companies_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX companies_to_tsvector_idx ON public.companies USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- Name: competitors_name_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX competitors_name_gin_trgm_idx ON public.competitors USING gin (name public.gin_trgm_ops);


--
-- Name: entities_to_tsvector_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX entities_to_tsvector_idx ON public.entities USING gin (to_tsvector('english'::regconfig, (name)::text));


--
-- Name: founders_city_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX founders_city_gin_trgm_idx ON public.founders USING gin (city public.gin_trgm_ops);


--
-- Name: index_calendar_events_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calendar_events_on_company_id ON public.calendar_events USING btree (company_id);


--
-- Name: index_calendar_events_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calendar_events_on_user_id ON public.calendar_events USING btree (user_id);


--
-- Name: index_cards_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cards_on_company_id ON public.cards USING btree (company_id);


--
-- Name: index_cards_on_list_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_cards_on_list_id ON public.cards USING btree (list_id);


--
-- Name: index_cards_on_trello_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_cards_on_trello_id ON public.cards USING btree (trello_id);


--
-- Name: index_companies_founders_on_company_id_and_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_founders_on_company_id_and_founder_id ON public.companies_founders USING btree (company_id, founder_id);


--
-- Name: index_companies_founders_on_founder_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_founders_on_founder_id_and_company_id ON public.companies_founders USING btree (founder_id, company_id);


--
-- Name: index_companies_on_al_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_al_id ON public.companies USING btree (al_id);


--
-- Name: index_companies_on_crunchbase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_crunchbase_id ON public.companies USING btree (crunchbase_id);


--
-- Name: index_companies_on_description; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_description ON public.companies USING btree (description);


--
-- Name: index_companies_on_domain; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_companies_on_domain ON public.companies USING btree (domain);


--
-- Name: index_companies_on_industry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_industry ON public.companies USING gin (industry);


--
-- Name: index_companies_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_location ON public.companies USING btree (location);


--
-- Name: index_companies_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_name ON public.companies USING btree (name);


--
-- Name: index_companies_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_on_team_id ON public.companies USING btree (team_id);


--
-- Name: index_companies_users_on_company_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_company_id_and_user_id ON public.companies_users USING btree (company_id, user_id);


--
-- Name: index_companies_users_on_user_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_companies_users_on_user_id_and_company_id ON public.companies_users USING btree (user_id, company_id);


--
-- Name: index_competitions_on_a_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitions_on_a_id ON public.competitions USING btree (a_id);


--
-- Name: index_competitions_on_a_id_and_b_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitions_on_a_id_and_b_id ON public.competitions USING btree (a_id, b_id);


--
-- Name: index_competitions_on_b_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitions_on_b_id ON public.competitions USING btree (b_id);


--
-- Name: index_competitor_coinvestors_on_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitor_coinvestors_on_competitor_id ON public.competitor_coinvestors USING btree (competitor_id);


--
-- Name: index_competitor_investor_aggs_on_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitor_investor_aggs_on_competitor_id ON public.competitor_investor_aggs USING btree (competitor_id);


--
-- Name: index_competitor_partners_on_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitor_partners_on_competitor_id ON public.competitor_partners USING btree (competitor_id);


--
-- Name: index_competitor_recent_investments_on_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitor_recent_investments_on_competitor_id ON public.competitor_recent_investments USING btree (competitor_id);


--
-- Name: index_competitor_velocities_on_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitor_velocities_on_competitor_id ON public.competitor_velocities USING btree (competitor_id);


--
-- Name: index_competitors_on_al_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitors_on_al_id ON public.competitors USING btree (al_id);


--
-- Name: index_competitors_on_crunchbase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitors_on_crunchbase_id ON public.competitors USING btree (crunchbase_id);


--
-- Name: index_competitors_on_domain; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitors_on_domain ON public.competitors USING btree (domain);


--
-- Name: index_competitors_on_fund_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitors_on_fund_type ON public.competitors USING gin (fund_type);


--
-- Name: index_competitors_on_industry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitors_on_industry ON public.competitors USING gin (industry);


--
-- Name: index_competitors_on_location; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_competitors_on_location ON public.competitors USING gin (location);


--
-- Name: index_competitors_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_competitors_on_name ON public.competitors USING btree (name);


--
-- Name: index_emails_on_bulk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_bulk ON public.emails USING btree (bulk);


--
-- Name: index_emails_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_company_id ON public.emails USING btree (company_id);


--
-- Name: index_emails_on_email_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_emails_on_email_id ON public.emails USING btree (email_id);


--
-- Name: index_emails_on_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_founder_id ON public.emails USING btree (founder_id);


--
-- Name: index_emails_on_intro_request_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_intro_request_id ON public.emails USING btree (intro_request_id);


--
-- Name: index_emails_on_investor_founder_dir_ca; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_investor_founder_dir_ca ON public.emails USING gin (investor_id, founder_id, direction, created_at);


--
-- Name: index_emails_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_emails_on_investor_id ON public.emails USING btree (investor_id);


--
-- Name: index_entities_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_entities_on_name ON public.entities USING btree (name);


--
-- Name: index_entities_on_wiki; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_entities_on_wiki ON public.entities USING btree (wiki);


--
-- Name: index_events_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_events_on_subject_type_and_subject_id ON public.events USING btree (subject_type, subject_id);


--
-- Name: index_founders_on_crunchbase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_crunchbase_id ON public.founders USING btree (crunchbase_id);


--
-- Name: index_founders_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_email ON public.founders USING btree (email);


--
-- Name: index_founders_on_facebook; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_facebook ON public.founders USING btree (facebook);


--
-- Name: index_founders_on_homepage; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_homepage ON public.founders USING btree (homepage);


--
-- Name: index_founders_on_linkedin; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_linkedin ON public.founders USING btree (linkedin);


--
-- Name: index_founders_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_token ON public.founders USING btree (token);


--
-- Name: index_founders_on_twitter; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_founders_on_twitter ON public.founders USING btree (twitter);


--
-- Name: index_import_tasks_on_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_import_tasks_on_founder_id ON public.import_tasks USING btree (founder_id);


--
-- Name: index_intro_requests_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intro_requests_on_company_id ON public.intro_requests USING btree (company_id);


--
-- Name: index_intro_requests_on_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intro_requests_on_founder_id ON public.intro_requests USING btree (founder_id);


--
-- Name: index_intro_requests_on_investor_founder_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_intro_requests_on_investor_founder_and_company_id ON public.intro_requests USING btree (investor_id, founder_id, company_id);


--
-- Name: index_intro_requests_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intro_requests_on_investor_id ON public.intro_requests USING btree (investor_id);


--
-- Name: index_intro_requests_on_target_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_intro_requests_on_target_investor_id ON public.intro_requests USING btree (target_investor_id);


--
-- Name: index_intro_requests_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_intro_requests_on_token ON public.intro_requests USING btree (token);


--
-- Name: index_investments_on_company_id_and_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investments_on_company_id_and_competitor_id ON public.investments USING btree (company_id, competitor_id);


--
-- Name: index_investments_on_competitor_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investments_on_competitor_id_and_company_id ON public.investments USING btree (competitor_id, company_id);


--
-- Name: index_investments_on_funded_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investments_on_funded_at ON public.investments USING btree (funded_at);


--
-- Name: index_investments_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investments_on_investor_id ON public.investments USING btree (investor_id);


--
-- Name: index_investor_entities_on_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investor_entities_on_competitor_id ON public.investor_entities USING btree (competitor_id);


--
-- Name: index_investor_entities_on_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investor_entities_on_count ON public.investor_entities USING btree (count);


--
-- Name: index_investor_entities_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investor_entities_on_entity_id ON public.investor_entities USING btree (entity_id);


--
-- Name: index_investor_entities_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investor_entities_on_investor_id ON public.investor_entities USING btree (investor_id);


--
-- Name: index_investor_entities_on_investor_id_and_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investor_entities_on_investor_id_and_entity_id ON public.investor_entities USING btree (investor_id, entity_id);


--
-- Name: index_investors_on_al_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_al_id ON public.investors USING btree (al_id);


--
-- Name: index_investors_on_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_competitor_id ON public.investors USING btree (competitor_id);


--
-- Name: index_investors_on_crunchbase_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_crunchbase_id ON public.investors USING btree (crunchbase_id);


--
-- Name: index_investors_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_email ON public.investors USING btree (email);


--
-- Name: index_investors_on_facebook; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_facebook ON public.investors USING btree (facebook);


--
-- Name: index_investors_on_featured; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_featured ON public.investors USING btree (featured);


--
-- Name: index_investors_on_first_name_and_last_name_and_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_first_name_and_last_name_and_competitor_id ON public.investors USING btree (first_name, last_name, competitor_id);


--
-- Name: index_investors_on_fund_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_fund_type ON public.investors USING gin (fund_type);


--
-- Name: index_investors_on_hidden; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_hidden ON public.investors USING btree (hidden);


--
-- Name: index_investors_on_homepage; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_homepage ON public.investors USING btree (homepage);


--
-- Name: index_investors_on_industry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_industry ON public.investors USING gin (industry);


--
-- Name: index_investors_on_linkedin; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_linkedin ON public.investors USING btree (linkedin);


--
-- Name: index_investors_on_photo; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_photo ON public.investors USING btree (photo);


--
-- Name: index_investors_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_token ON public.investors USING btree (token);


--
-- Name: index_investors_on_twitter; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_investors_on_twitter ON public.investors USING btree (twitter);


--
-- Name: index_investors_on_university_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_university_id ON public.investors USING btree (university_id);


--
-- Name: index_investors_on_verified; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_investors_on_verified ON public.investors USING btree (verified);


--
-- Name: index_knowledges_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledges_on_team_id ON public.knowledges USING btree (team_id);


--
-- Name: index_knowledges_on_ts; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_knowledges_on_ts ON public.knowledges USING btree (ts);


--
-- Name: index_knowledges_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_knowledges_on_user_id ON public.knowledges USING btree (user_id);


--
-- Name: index_lists_on_pos_and_trello_board_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lists_on_pos_and_trello_board_id ON public.lists USING btree (pos, trello_board_id);


--
-- Name: index_lists_on_trello_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_lists_on_trello_id ON public.lists USING btree (trello_id);


--
-- Name: index_logged_events_on_reason_and_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_logged_events_on_reason_and_record_id ON public.logged_events USING btree (reason, record_id);


--
-- Name: index_news_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_on_company_id ON public.news USING btree (company_id);


--
-- Name: index_news_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_on_investor_id ON public.news USING btree (investor_id);


--
-- Name: index_news_on_url_and_investor_id_and_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_news_on_url_and_investor_id_and_company_id ON public.news USING btree (url, investor_id, company_id);


--
-- Name: index_notes_on_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_founder_id ON public.notes USING btree (founder_id);


--
-- Name: index_notes_on_subject_type_and_subject_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_subject_type_and_subject_id ON public.notes USING btree (subject_type, subject_id);


--
-- Name: index_person_entities_on_entity_and_person; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_person_entities_on_entity_and_person ON public.person_entities USING btree (entity_id, person_type, person_id);


--
-- Name: index_person_entities_on_entity_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_person_entities_on_entity_id ON public.person_entities USING btree (entity_id);


--
-- Name: index_person_entities_on_person_type_and_person_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_person_entities_on_person_type_and_person_id ON public.person_entities USING btree (person_type, person_id);


--
-- Name: index_pitches_on_card_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pitches_on_card_id ON public.pitches USING btree (card_id);


--
-- Name: index_pitches_on_company_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pitches_on_company_id ON public.pitches USING btree (company_id);


--
-- Name: index_pitches_on_prevote_doc; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pitches_on_prevote_doc ON public.pitches USING btree (prevote_doc);


--
-- Name: index_pitches_on_snapshot; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_pitches_on_snapshot ON public.pitches USING btree (snapshot);


--
-- Name: index_posts_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_investor_id ON public.posts USING btree (investor_id);


--
-- Name: index_target_investors_on_competitor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_target_investors_on_competitor_id ON public.target_investors USING btree (competitor_id);


--
-- Name: index_target_investors_on_first_last_firm_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_target_investors_on_first_last_firm_name ON public.target_investors USING btree (first_name, last_name, firm_name, founder_id);


--
-- Name: index_target_investors_on_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_target_investors_on_founder_id ON public.target_investors USING btree (founder_id);


--
-- Name: index_target_investors_on_fund_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_target_investors_on_fund_type ON public.target_investors USING gin (fund_type);


--
-- Name: index_target_investors_on_industry; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_target_investors_on_industry ON public.target_investors USING gin (industry);


--
-- Name: index_target_investors_on_investor_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_target_investors_on_investor_id ON public.target_investors USING btree (investor_id);


--
-- Name: index_target_investors_on_investor_id_and_founder_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_target_investors_on_investor_id_and_founder_id ON public.target_investors USING btree (investor_id, founder_id);


--
-- Name: index_teams_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_teams_on_name ON public.teams USING btree (name);


--
-- Name: index_tracking_pixels_on_email_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tracking_pixels_on_email_id ON public.tracking_pixels USING btree (email_id);


--
-- Name: index_tracking_pixels_on_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tracking_pixels_on_token ON public.tracking_pixels USING btree (token);


--
-- Name: index_tweeters_on_owner_type_and_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tweeters_on_owner_type_and_owner_id ON public.tweeters USING btree (owner_type, owner_id);


--
-- Name: index_tweeters_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tweeters_on_username ON public.tweeters USING btree (username);


--
-- Name: index_tweets_on_tweeter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tweets_on_tweeter_id ON public.tweets USING btree (tweeter_id);


--
-- Name: index_tweets_on_twitter_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tweets_on_twitter_id ON public.tweets USING btree (twitter_id);


--
-- Name: index_universities_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_universities_on_name ON public.universities USING btree (name);


--
-- Name: index_users_on_cached_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_cached_name ON public.users USING btree (cached_name);


--
-- Name: index_users_on_slack_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_slack_id ON public.users USING btree (slack_id);


--
-- Name: index_users_on_team_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_team_id ON public.users USING btree (team_id);


--
-- Name: index_users_on_trello_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_trello_id ON public.users USING btree (trello_id);


--
-- Name: index_users_on_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_username ON public.users USING btree (username);


--
-- Name: index_votes_on_pitch_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_pitch_id ON public.votes USING btree (pitch_id);


--
-- Name: index_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_votes_on_user_id ON public.votes USING btree (user_id);


--
-- Name: investors_first_name_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX investors_first_name_gin_trgm_idx ON public.investors USING gin (first_name public.gin_trgm_ops);


--
-- Name: investors_last_name_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX investors_last_name_gin_trgm_idx ON public.investors USING gin (last_name public.gin_trgm_ops);


--
-- Name: investors_location_gin_trgm_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX investors_location_gin_trgm_idx ON public.investors USING gin (location public.gin_trgm_ops);


--
-- Name: investors_to_tsvector_fname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX investors_to_tsvector_fname ON public.investors USING gin (to_tsvector('english'::regconfig, (first_name)::text));


--
-- Name: investors_to_tsvector_lname; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX investors_to_tsvector_lname ON public.investors USING gin (to_tsvector('english'::regconfig, (last_name)::text));


--
-- Name: trgm_name_indx_on_entities; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trgm_name_indx_on_entities ON public.entities USING gist (name public.gist_trgm_ops);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_schema_migrations ON public.schema_migrations USING btree (version);


--
-- Name: emails fk_rails_041ca7bd32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT fk_rails_041ca7bd32 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: intro_requests fk_rails_0c534c3fde; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intro_requests
    ADD CONSTRAINT fk_rails_0c534c3fde FOREIGN KEY (target_investor_id) REFERENCES public.target_investors(id);


--
-- Name: investments fk_rails_0d6258ac3c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.investments
    ADD CONSTRAINT fk_rails_0d6258ac3c FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: competitions fk_rails_10c7683510; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitions
    ADD CONSTRAINT fk_rails_10c7683510 FOREIGN KEY (a_id) REFERENCES public.companies(id);


--
-- Name: pitches fk_rails_115ef0c2b5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pitches
    ADD CONSTRAINT fk_rails_115ef0c2b5 FOREIGN KEY (card_id) REFERENCES public.cards(id);


--
-- Name: cards fk_rails_11b32bc490; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT fk_rails_11b32bc490 FOREIGN KEY (list_id) REFERENCES public.lists(id);


--
-- Name: import_tasks fk_rails_1705f4b9e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.import_tasks
    ADD CONSTRAINT fk_rails_1705f4b9e0 FOREIGN KEY (founder_id) REFERENCES public.founders(id);


--
-- Name: intro_requests fk_rails_203146869d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intro_requests
    ADD CONSTRAINT fk_rails_203146869d FOREIGN KEY (investor_id) REFERENCES public.investors(id);


--
-- Name: investments fk_rails_212f793a38; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.investments
    ADD CONSTRAINT fk_rails_212f793a38 FOREIGN KEY (competitor_id) REFERENCES public.competitors(id);


--
-- Name: knowledges fk_rails_26ba4c0c3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledges
    ADD CONSTRAINT fk_rails_26ba4c0c3e FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: posts fk_rails_285bce5540; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT fk_rails_285bce5540 FOREIGN KEY (investor_id) REFERENCES public.investors(id);


--
-- Name: competitions fk_rails_297510c89c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.competitions
    ADD CONSTRAINT fk_rails_297510c89c FOREIGN KEY (b_id) REFERENCES public.companies(id);


--
-- Name: cards fk_rails_31e9cb1159; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT fk_rails_31e9cb1159 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: emails fk_rails_4f7e384dec; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT fk_rails_4f7e384dec FOREIGN KEY (intro_request_id) REFERENCES public.intro_requests(id);


--
-- Name: tracking_pixels fk_rails_586fbe02f8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tracking_pixels
    ADD CONSTRAINT fk_rails_586fbe02f8 FOREIGN KEY (email_id) REFERENCES public.emails(id);


--
-- Name: investors fk_rails_5e5b9710a2; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.investors
    ADD CONSTRAINT fk_rails_5e5b9710a2 FOREIGN KEY (university_id) REFERENCES public.universities(id);


--
-- Name: emails fk_rails_602d137517; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT fk_rails_602d137517 FOREIGN KEY (investor_id) REFERENCES public.investors(id);


--
-- Name: news fk_rails_646d2bd38d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT fk_rails_646d2bd38d FOREIGN KEY (investor_id) REFERENCES public.investors(id);


--
-- Name: person_entities fk_rails_6d42d0b8bf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.person_entities
    ADD CONSTRAINT fk_rails_6d42d0b8bf FOREIGN KEY (entity_id) REFERENCES public.entities(id);


--
-- Name: votes fk_rails_8455b71b47; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT fk_rails_8455b71b47 FOREIGN KEY (pitch_id) REFERENCES public.pitches(id);


--
-- Name: pitches fk_rails_87434cc962; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pitches
    ADD CONSTRAINT fk_rails_87434cc962 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: calendar_events fk_rails_930e3c0bf4; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT fk_rails_930e3c0bf4 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: target_investors fk_rails_9cfe54f56c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.target_investors
    ADD CONSTRAINT fk_rails_9cfe54f56c FOREIGN KEY (founder_id) REFERENCES public.founders(id);


--
-- Name: users fk_rails_b2bbf87303; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_rails_b2bbf87303 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: intro_requests fk_rails_b2d35a8529; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intro_requests
    ADD CONSTRAINT fk_rails_b2d35a8529 FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: investors fk_rails_bfbc7d2c7a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.investors
    ADD CONSTRAINT fk_rails_bfbc7d2c7a FOREIGN KEY (competitor_id) REFERENCES public.competitors(id);


--
-- Name: calendar_events fk_rails_c3e3b9423b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT fk_rails_c3e3b9423b FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: target_investors fk_rails_c8ec711f83; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.target_investors
    ADD CONSTRAINT fk_rails_c8ec711f83 FOREIGN KEY (competitor_id) REFERENCES public.competitors(id);


--
-- Name: votes fk_rails_c9b3bef597; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.votes
    ADD CONSTRAINT fk_rails_c9b3bef597 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: notes fk_rails_d6c54b7443; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_d6c54b7443 FOREIGN KEY (founder_id) REFERENCES public.founders(id);


--
-- Name: knowledges fk_rails_d823280e2d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.knowledges
    ADD CONSTRAINT fk_rails_d823280e2d FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: intro_requests fk_rails_d87bff6194; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intro_requests
    ADD CONSTRAINT fk_rails_d87bff6194 FOREIGN KEY (founder_id) REFERENCES public.founders(id);


--
-- Name: news fk_rails_ddd1ba457d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news
    ADD CONSTRAINT fk_rails_ddd1ba457d FOREIGN KEY (company_id) REFERENCES public.companies(id);


--
-- Name: investments fk_rails_e0aa7acb5f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.investments
    ADD CONSTRAINT fk_rails_e0aa7acb5f FOREIGN KEY (investor_id) REFERENCES public.investors(id);


--
-- Name: emails fk_rails_f6176d396e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.emails
    ADD CONSTRAINT fk_rails_f6176d396e FOREIGN KEY (founder_id) REFERENCES public.founders(id);


--
-- Name: companies fk_rails_f7f30b55b8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.companies
    ADD CONSTRAINT fk_rails_f7f30b55b8 FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: target_investors fk_rails_fb3356619c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.target_investors
    ADD CONSTRAINT fk_rails_fb3356619c FOREIGN KEY (investor_id) REFERENCES public.investors(id);


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
('20171210093034'),
('20171222033118'),
('20171222074015'),
('20171227002601'),
('20171228000038'),
('20171229082041'),
('20180104062301'),
('20180104120408'),
('20180115225738'),
('20180115230519'),
('20180116003132'),
('20180116010539'),
('20180116013512'),
('20180116192204'),
('20180117090330'),
('20180117230808'),
('20180118014509'),
('20180118015010'),
('20180124100122'),
('20180124101142'),
('20180124101553'),
('20180124102250'),
('20180124202440'),
('20180124235326'),
('20180125174538'),
('20180130063518'),
('20180130064719'),
('20180130165807'),
('20180202174934'),
('20180202175706'),
('20180203050854'),
('20180404032450'),
('20180624224942'),
('20180921073712');


