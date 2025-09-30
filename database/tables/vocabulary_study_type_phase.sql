-- Name: vocabulary_study_type_phase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_study_type_phase (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--

-- Name: vocabulary_study_type_phase_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_study_type_phase_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: vocabulary_study_type_phase_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_study_type_phase_id_seq OWNED BY public.vocabulary_study_type_phase.id;


--

-- Name: vocabulary_study_type_phase id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_phase ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_study_type_phase_id_seq'::regclass);


--

-- Name: vocabulary_study_type_phase vocabulary_study_type_phase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_phase
    ADD CONSTRAINT vocabulary_study_type_phase_pkey PRIMARY KEY (id);


--
