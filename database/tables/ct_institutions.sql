-- Name: ct_institutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_institutions (
    id integer NOT NULL,
    trial_id integer,
    name character varying(255),
    address text,
    city character varying(255),
    state character varying(255),
    country integer,
    type_id integer
);


--

-- Name: ct_institutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_institutions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_institutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_institutions_id_seq OWNED BY public.ct_institutions.id;


--

-- Name: ct_institutions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_institutions ALTER COLUMN id SET DEFAULT nextval('public.ct_institutions_id_seq'::regclass);


--

-- Name: ct_institutions ct_institutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_institutions
    ADD CONSTRAINT ct_institutions_pkey PRIMARY KEY (id);


--

-- Name: ct_institutions ct_institutions_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_institutions
    ADD CONSTRAINT ct_institutions_country_fkey FOREIGN KEY (country) REFERENCES public.vocabulary_country(id);


--

-- Name: ct_institutions ct_institutions_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_institutions
    ADD CONSTRAINT ct_institutions_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--

-- Name: ct_institutions ct_institutions_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_institutions
    ADD CONSTRAINT ct_institutions_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.vocabulary_institution_type(id);


--
