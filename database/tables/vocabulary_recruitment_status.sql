-- Name: vocabulary_recruitment_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_recruitment_status (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--

-- Name: vocabulary_recruitment_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_recruitment_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: vocabulary_recruitment_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_recruitment_status_id_seq OWNED BY public.vocabulary_recruitment_status.id;


--

-- Name: vocabulary_recruitment_status id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_recruitment_status ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_recruitment_status_id_seq'::regclass);


--

-- Name: vocabulary_recruitment_status vocabulary_recruitment_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_recruitment_status
    ADD CONSTRAINT vocabulary_recruitment_status_pkey PRIMARY KEY (id);


--
