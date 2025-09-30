-- Name: ct_country_of_recruitment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_country_of_recruitment (
    id integer NOT NULL,
    trial_id integer,
    country character varying(100)
);


--

-- Name: ct_country_of_recruitment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_country_of_recruitment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_country_of_recruitment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_country_of_recruitment_id_seq OWNED BY public.ct_country_of_recruitment.id;


--

-- Name: ct_country_of_recruitment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_country_of_recruitment ALTER COLUMN id SET DEFAULT nextval('public.ct_country_of_recruitment_id_seq'::regclass);


--

-- Name: ct_country_of_recruitment ct_country_of_recruitment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_country_of_recruitment
    ADD CONSTRAINT ct_country_of_recruitment_pkey PRIMARY KEY (id);


--

-- Name: ct_country_of_recruitment ct_country_of_recruitment_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_country_of_recruitment
    ADD CONSTRAINT ct_country_of_recruitment_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
