-- Name: ct_study_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_study_type (
    id integer NOT NULL,
    trial_id integer,
    expanded_access_program integer,
    purpose integer,
    intervention_assignment integer,
    number_of_arms integer,
    masking_type integer,
    alocation_type integer,
    study_phase integer,
    observational_study_design integer,
    temporality integer
);


--

-- Name: ct_study_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_study_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_study_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_study_type_id_seq OWNED BY public.ct_study_type.id;


--

-- Name: ct_study_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type ALTER COLUMN id SET DEFAULT nextval('public.ct_study_type_id_seq'::regclass);


--

-- Name: ct_study_type ct_study_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_pkey PRIMARY KEY (id);


--

-- Name: ct_study_type ct_study_type_alocation_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_alocation_type_fkey FOREIGN KEY (alocation_type) REFERENCES public.vocabulary_study_alocation(id);


--

-- Name: ct_study_type ct_study_type_expanded_access_program_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_expanded_access_program_fkey FOREIGN KEY (expanded_access_program) REFERENCES public.vocabulary_study_type_expanded_access(id);


--

-- Name: ct_study_type ct_study_type_intervention_assignment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_intervention_assignment_fkey FOREIGN KEY (intervention_assignment) REFERENCES public.vocabulary_study_type_intervention_assignment(id);


--

-- Name: ct_study_type ct_study_type_masking_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_masking_type_fkey FOREIGN KEY (masking_type) REFERENCES public.vocabulary_study_type_masking(id);


--

-- Name: ct_study_type ct_study_type_observational_study_design_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_observational_study_design_fkey FOREIGN KEY (observational_study_design) REFERENCES public.vocabulary_study_type_obs_study_design(id);


--

-- Name: ct_study_type ct_study_type_purpose_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_purpose_fkey FOREIGN KEY (purpose) REFERENCES public.vocabulary_study_type_purpose(id);


--

-- Name: ct_study_type ct_study_type_study_phase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_study_phase_fkey FOREIGN KEY (study_phase) REFERENCES public.vocabulary_study_type_phase(id);


--

-- Name: ct_study_type ct_study_type_temporality_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_temporality_fkey FOREIGN KEY (temporality) REFERENCES public.vocabulary_study_type_temporality(id);


--

-- Name: ct_study_type ct_study_type_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
