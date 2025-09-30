-- Name: research_institutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.research_institutions (
    id integer NOT NULL,
    name character varying(255),
    address text,
    city character varying(255),
    state character varying(255),
    country_id integer,
    type_id integer,
    approved boolean DEFAULT false
);


--

-- Name: research_institutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.research_institutions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: research_institutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.research_institutions_id_seq OWNED BY public.research_institutions.id;


--

-- Name: research_institutions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.research_institutions ALTER COLUMN id SET DEFAULT nextval('public.research_institutions_id_seq'::regclass);


--

-- Name: research_institutions research_institutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.research_institutions
    ADD CONSTRAINT research_institutions_pkey PRIMARY KEY (id);


--

-- Name: research_institutions research_institutions_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.research_institutions
    ADD CONSTRAINT research_institutions_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.vocabulary_country(id);


--

-- Name: research_institutions research_institutions_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.research_institutions
    ADD CONSTRAINT research_institutions_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.vocabulary_institution_type(id);


--
-- PostgreSQL database dump complete
--
