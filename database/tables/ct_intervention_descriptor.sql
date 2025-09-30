-- Name: ct_intervention_descriptor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_intervention_descriptor (
    id integer NOT NULL,
    trial_id integer,
    intervention_descriptor_type integer,
    intervention_descriptor_vocabulary integer,
    intervention_descriptor_code character varying(255),
    intervention_descriptor character varying(255),
    intervention_descriptor_pt character varying(255)
);


--

-- Name: ct_intervention_descriptor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_intervention_descriptor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_intervention_descriptor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_intervention_descriptor_id_seq OWNED BY public.ct_intervention_descriptor.id;


--

-- Name: ct_intervention_descriptor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention_descriptor ALTER COLUMN id SET DEFAULT nextval('public.ct_intervention_descriptor_id_seq'::regclass);


--

-- Name: ct_intervention_descriptor ct_intervention_descriptor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention_descriptor
    ADD CONSTRAINT ct_intervention_descriptor_pkey PRIMARY KEY (id);


--

-- Name: ct_intervention_descriptor ct_intervention_descriptor_intervention_descriptor_vocabul_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention_descriptor
    ADD CONSTRAINT ct_intervention_descriptor_intervention_descriptor_vocabul_fkey FOREIGN KEY (intervention_descriptor_vocabulary) REFERENCES public.vocabulary_health_condition_code_vocabulary(id);


--

-- Name: ct_intervention_descriptor ct_intervention_descriptor_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention_descriptor
    ADD CONSTRAINT ct_intervention_descriptor_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
