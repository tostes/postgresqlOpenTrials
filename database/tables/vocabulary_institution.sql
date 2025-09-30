-- Name: vocabulary_institution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_institution (
    id integer NOT NULL,
    name character varying(255),
    address text,
    state character varying(255),
    city character varying(255),
    country character varying(255),
    institution_type character varying(255),
    is_active boolean DEFAULT true
);


--

-- Name: vocabulary_institution_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_institution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: vocabulary_institution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_institution_id_seq OWNED BY public.vocabulary_institution.id;


--

-- Name: vocabulary_institution id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_institution ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_institution_id_seq'::regclass);


--

-- Name: vocabulary_institution vocabulary_institution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_institution
    ADD CONSTRAINT vocabulary_institution_pkey PRIMARY KEY (id);


--
