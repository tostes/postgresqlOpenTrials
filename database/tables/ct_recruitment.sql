-- Name: ct_recruitment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_recruitment (
    id integer NOT NULL,
    trial_id integer,
    first_date_enrollment date,
    last_date_enrollment date,
    target_sample_size integer,
    inclusion_criteria text,
    inclusion_criteria_native text,
    exclusion_criteria text,
    exclusion_criteria_native text,
    age_minimum integer,
    unit_age_minimum character varying(50),
    age_maximum integer,
    unit_age_maximum character varying(50)
);


--

-- Name: ct_recruitment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_recruitment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_recruitment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_recruitment_id_seq OWNED BY public.ct_recruitment.id;


--

-- Name: ct_recruitment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_recruitment ALTER COLUMN id SET DEFAULT nextval('public.ct_recruitment_id_seq'::regclass);


--

-- Name: ct_recruitment ct_recruitment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_recruitment
    ADD CONSTRAINT ct_recruitment_pkey PRIMARY KEY (id);


--

-- Name: ct_recruitment ct_recruitment_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_recruitment
    ADD CONSTRAINT ct_recruitment_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
