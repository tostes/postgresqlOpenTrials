-- Name: ct_outcome; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_outcome (
    id integer NOT NULL,
    trial_id integer,
    outcome_type integer,
    outcome_name character varying(255),
    time_point character varying(255),
    measure character varying(255),
    objectives character varying(255),
    endpoints character varying(255),
    description text,
    description_native text
);


--

-- Name: ct_outcome_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_outcome_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_outcome_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_outcome_id_seq OWNED BY public.ct_outcome.id;


--

-- Name: ct_outcome id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_outcome ALTER COLUMN id SET DEFAULT nextval('public.ct_outcome_id_seq'::regclass);


--

-- Name: ct_outcome ct_outcome_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_outcome
    ADD CONSTRAINT ct_outcome_pkey PRIMARY KEY (id);


--

-- Name: ct_outcome ct_outcome_outcome_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_outcome
    ADD CONSTRAINT ct_outcome_outcome_type_fkey FOREIGN KEY (outcome_type) REFERENCES public.vocabulary_outcome_type(id);


--

-- Name: ct_outcome ct_outcome_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_outcome
    ADD CONSTRAINT ct_outcome_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
