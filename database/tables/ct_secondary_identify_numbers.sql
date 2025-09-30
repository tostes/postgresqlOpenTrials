-- Name: ct_secondary_identify_numbers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_secondary_identify_numbers (
    id integer NOT NULL,
    trial_id integer,
    identify_type integer,
    identify_code character varying(255),
    issuing_institution character varying(255)
);


--

-- Name: ct_secondary_identify_numbers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_secondary_identify_numbers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_secondary_identify_numbers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_secondary_identify_numbers_id_seq OWNED BY public.ct_secondary_identify_numbers.id;


--

-- Name: ct_secondary_identify_numbers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_secondary_identify_numbers ALTER COLUMN id SET DEFAULT nextval('public.ct_secondary_identify_numbers_id_seq'::regclass);


--

-- Name: ct_secondary_identify_numbers ct_secondary_identify_numbers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_secondary_identify_numbers
    ADD CONSTRAINT ct_secondary_identify_numbers_pkey PRIMARY KEY (id);


--

-- Name: ct_secondary_identify_numbers ct_secondary_identify_numbers_identify_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_secondary_identify_numbers
    ADD CONSTRAINT ct_secondary_identify_numbers_identify_type_fkey FOREIGN KEY (identify_type) REFERENCES public.vocabulary_secondary_identify_type(id);


--

-- Name: ct_secondary_identify_numbers ct_secondary_identify_numbers_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_secondary_identify_numbers
    ADD CONSTRAINT ct_secondary_identify_numbers_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
