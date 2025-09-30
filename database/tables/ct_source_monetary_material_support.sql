-- Name: ct_source_monetary_material_support; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_source_monetary_material_support (
    id integer NOT NULL,
    trial_id integer,
    source_name character varying(255),
    source_type character varying(255),
    support_type integer
);


--

-- Name: ct_source_monetary_material_support_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_source_monetary_material_support_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_source_monetary_material_support_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_source_monetary_material_support_id_seq OWNED BY public.ct_source_monetary_material_support.id;


--

-- Name: ct_source_monetary_material_support id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_source_monetary_material_support ALTER COLUMN id SET DEFAULT nextval('public.ct_source_monetary_material_support_id_seq'::regclass);


--

-- Name: ct_source_monetary_material_support ct_source_monetary_material_support_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_source_monetary_material_support
    ADD CONSTRAINT ct_source_monetary_material_support_pkey PRIMARY KEY (id);


--

-- Name: ct_source_monetary_material_support ct_source_monetary_material_support_support_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_source_monetary_material_support
    ADD CONSTRAINT ct_source_monetary_material_support_support_type_fkey FOREIGN KEY (support_type) REFERENCES public.vocabulary_monetary_material_support_type(id);


--

-- Name: ct_source_monetary_material_support ct_source_monetary_material_support_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_source_monetary_material_support
    ADD CONSTRAINT ct_source_monetary_material_support_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
