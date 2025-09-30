-- Name: ct; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct (
    id integer NOT NULL,
    creator_id integer,
    register_id character varying(100),
    study_type integer,
    public_title character varying(255) NOT NULL,
    public_title_native character varying(255) NOT NULL,
    scientific_title character varying(255) NOT NULL,
    scientific_title_native character varying(255) NOT NULL,
    recruitment_status integer,
    completion_date date,
    trial_url character varying(255)
);


--

-- Name: ct_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_id_seq OWNED BY public.ct.id;


--

-- Name: ct id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct ALTER COLUMN id SET DEFAULT nextval('public.ct_id_seq'::regclass);


--

-- Name: ct ct_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct
    ADD CONSTRAINT ct_pkey PRIMARY KEY (id);


--

-- Name: ct ct_recruitment_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct
    ADD CONSTRAINT ct_recruitment_status_fkey FOREIGN KEY (recruitment_status) REFERENCES public.vocabulary_recruitment_status(id);


--

-- Name: ct ct_study_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct
    ADD CONSTRAINT ct_study_type_fkey FOREIGN KEY (study_type) REFERENCES public.vocabulary_intervention(id);


--
