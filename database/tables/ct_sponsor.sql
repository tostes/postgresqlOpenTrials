-- Name: ct_sponsor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_sponsor (
    id integer NOT NULL,
    trial_id integer,
    institution_id integer,
    is_primary_sponsor boolean DEFAULT false,
    is_secondary_sponsor boolean DEFAULT false,
    is_monetary_support boolean DEFAULT false,
    source_type character varying(255)
);


--

-- Name: ct_sponsor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_sponsor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_sponsor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_sponsor_id_seq OWNED BY public.ct_sponsor.id;


--

-- Name: ct_sponsor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_sponsor ALTER COLUMN id SET DEFAULT nextval('public.ct_sponsor_id_seq'::regclass);


--

-- Name: ct_sponsor ct_sponsor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_sponsor
    ADD CONSTRAINT ct_sponsor_pkey PRIMARY KEY (id);


--

-- Name: ct_sponsor ct_sponsor_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_sponsor
    ADD CONSTRAINT ct_sponsor_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
