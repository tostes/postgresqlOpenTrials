-- Name: ct_health_condition_problem_study; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_health_condition_problem_study (
    id integer NOT NULL,
    trial_id integer,
    health_condition text,
    health_condition_native text,
    health_condition_code character varying(255),
    health_condition_code_type integer,
    health_condition_code_vocabulary integer,
    health_condition_keyword character varying(255)
);


--

-- Name: ct_health_condition_problem_study_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_health_condition_problem_study_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_health_condition_problem_study_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_health_condition_problem_study_id_seq OWNED BY public.ct_health_condition_problem_study.id;


--

-- Name: ct_health_condition_problem_study id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_health_condition_problem_study ALTER COLUMN id SET DEFAULT nextval('public.ct_health_condition_problem_study_id_seq'::regclass);


--

-- Name: ct_health_condition_problem_study ct_health_condition_problem_study_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_health_condition_problem_study
    ADD CONSTRAINT ct_health_condition_problem_study_pkey PRIMARY KEY (id);


--

-- Name: ct_health_condition_problem_study ct_health_condition_problem_s_health_condition_code_vocabu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_health_condition_problem_study
    ADD CONSTRAINT ct_health_condition_problem_s_health_condition_code_vocabu_fkey FOREIGN KEY (health_condition_code_vocabulary) REFERENCES public.vocabulary_health_condition_code_vocabulary(id);


--

-- Name: ct_health_condition_problem_study ct_health_condition_problem_stu_health_condition_code_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_health_condition_problem_study
    ADD CONSTRAINT ct_health_condition_problem_stu_health_condition_code_type_fkey FOREIGN KEY (health_condition_code_type) REFERENCES public.vocabulary_health_condition_code_type(id);


--

-- Name: ct_health_condition_problem_study ct_health_condition_problem_study_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_health_condition_problem_study
    ADD CONSTRAINT ct_health_condition_problem_study_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
