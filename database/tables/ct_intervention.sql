-- Name: ct_intervention; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_intervention (
    id integer NOT NULL,
    trial_id integer,
    intervention_description text,
    intervention_description_pt text,
    is_drug boolean DEFAULT false,
    is_device boolean DEFAULT false,
    is_biological_vacina boolean DEFAULT false,
    is_procedure_surgery boolean DEFAULT false,
    is_radiation boolean DEFAULT false,
    is_behavioural boolean DEFAULT false,
    is_genetics boolean DEFAULT false,
    is_diatary_supplement boolean DEFAULT false,
    is_other boolean DEFAULT false
);


--

-- Name: ct_intervention_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_intervention_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_intervention_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_intervention_id_seq OWNED BY public.ct_intervention.id;


--

-- Name: ct_intervention id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention ALTER COLUMN id SET DEFAULT nextval('public.ct_intervention_id_seq'::regclass);


--

-- Name: ct_intervention ct_intervention_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention
    ADD CONSTRAINT ct_intervention_pkey PRIMARY KEY (id);


--

-- Name: ct_intervention ct_intervention_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention
    ADD CONSTRAINT ct_intervention_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
