-- Name: ct_editor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_editor (
    id integer NOT NULL,
    owner_id integer,
    trial_id integer,
    editor_id integer
);


--

-- Name: ct_editor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_editor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: ct_editor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_editor_id_seq OWNED BY public.ct_editor.id;


--

-- Name: ct_editor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_editor ALTER COLUMN id SET DEFAULT nextval('public.ct_editor_id_seq'::regclass);


--

-- Name: ct_editor ct_editor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_editor
    ADD CONSTRAINT ct_editor_pkey PRIMARY KEY (id);


--

-- Name: ct_editor ct_editor_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_editor
    ADD CONSTRAINT ct_editor_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
