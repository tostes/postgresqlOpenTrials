-- Name: ct_data_sharing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_data_sharing (
    id integer NOT NULL,
    trial_id integer,
    data_sharing_plan integer,
    data_sharing_description text,
    data_sharing_description_native text
);


--

-- Name: ct_data_sharing_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_data_sharing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_data_sharing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_data_sharing_id_seq OWNED BY public.ct_data_sharing.id;


--

-- Name: ct_data_sharing id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_data_sharing ALTER COLUMN id SET DEFAULT nextval('public.ct_data_sharing_id_seq'::regclass);


--

-- Name: ct_data_sharing ct_data_sharing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_data_sharing
    ADD CONSTRAINT ct_data_sharing_pkey PRIMARY KEY (id);


--

-- Name: ct_data_sharing ct_data_sharing_data_sharing_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_data_sharing
    ADD CONSTRAINT ct_data_sharing_data_sharing_plan_fkey FOREIGN KEY (data_sharing_plan) REFERENCES public.vocabulary_data_sharing_plan(id);


--

-- Name: ct_data_sharing ct_data_sharing_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_data_sharing
    ADD CONSTRAINT ct_data_sharing_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
