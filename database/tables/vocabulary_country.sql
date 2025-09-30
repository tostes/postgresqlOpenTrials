-- Name: vocabulary_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_country (
    id integer NOT NULL,
    country_en character varying(255),
    country_pt character varying(255),
    country_es character varying(255),
    country_label character varying(255)
);


--

-- Name: vocabulary_country_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: vocabulary_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_country_id_seq OWNED BY public.vocabulary_country.id;


--

-- Name: vocabulary_country id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_country ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_country_id_seq'::regclass);


--

-- Name: vocabulary_country vocabulary_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_country
    ADD CONSTRAINT vocabulary_country_pkey PRIMARY KEY (id);


--
