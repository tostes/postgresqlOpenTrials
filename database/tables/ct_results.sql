-- Name: ct_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_results (
    id integer NOT NULL,
    trial_id integer,
    publication_date date,
    results_url character varying(255),
    baseline text,
    baseline_native text,
    participants_flow text,
    participants_flow_native text,
    adverse_events text,
    adverse_events_native text,
    outcome_mesure text,
    outcome_mesure_native text,
    protocol_url character varying(255),
    sumary_results text,
    sumary_results_native text
);


--

-- Name: ct_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_results_id_seq OWNED BY public.ct_results.id;


--

-- Name: ct_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_results ALTER COLUMN id SET DEFAULT nextval('public.ct_results_id_seq'::regclass);


--

-- Name: ct_results ct_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_results
    ADD CONSTRAINT ct_results_pkey PRIMARY KEY (id);


--

-- Name: ct_results ct_results_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_results
    ADD CONSTRAINT ct_results_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
