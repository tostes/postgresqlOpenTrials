-- Name: ct_contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_contact (
    id integer NOT NULL,
    trial_id integer,
    first_name character varying(255),
    middle_name character varying(255),
    last_name character varying(255),
    address text,
    city character varying(100),
    country character varying(100),
    zip_code character varying(20),
    telephone character varying(50),
    email character varying(255),
    affiliation integer,
    is_public_contact boolean DEFAULT false,
    is_scientific_contact boolean DEFAULT false,
    is_site_contact boolean DEFAULT false,
    is_ethic_contact boolean DEFAULT false
);


--

-- Name: ct_contact_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_contact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_contact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_contact_id_seq OWNED BY public.ct_contact.id;


--

-- Name: ct_contact id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_contact ALTER COLUMN id SET DEFAULT nextval('public.ct_contact_id_seq'::regclass);


--

-- Name: ct_contact ct_contact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_contact
    ADD CONSTRAINT ct_contact_pkey PRIMARY KEY (id);


--

-- Name: ct_contact ct_contact_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_contact
    ADD CONSTRAINT ct_contact_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
