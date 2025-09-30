-- Name: ct_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_attachments (
    id integer NOT NULL,
    trial_id integer,
    attachment_type integer,
    is_public boolean DEFAULT false,
    attachment_link character varying(255),
    attachment character varying(255)
);


--

-- Name: ct_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_attachments_id_seq OWNED BY public.ct_attachments.id;


--

-- Name: ct_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_attachments ALTER COLUMN id SET DEFAULT nextval('public.ct_attachments_id_seq'::regclass);


--

-- Name: ct_attachments ct_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_attachments
    ADD CONSTRAINT ct_attachments_pkey PRIMARY KEY (id);


--

-- Name: ct_attachments ct_attachments_attachment_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_attachments
    ADD CONSTRAINT ct_attachments_attachment_type_fkey FOREIGN KEY (attachment_type) REFERENCES public.vocabulary_attachment_type(id);


--

-- Name: ct_attachments ct_attachments_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_attachments
    ADD CONSTRAINT ct_attachments_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
