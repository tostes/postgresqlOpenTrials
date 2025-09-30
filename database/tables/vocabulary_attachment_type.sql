-- Name: vocabulary_attachment_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_attachment_type (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--

-- Name: vocabulary_attachment_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_attachment_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: vocabulary_attachment_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_attachment_type_id_seq OWNED BY public.vocabulary_attachment_type.id;


--

-- Name: vocabulary_attachment_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_attachment_type ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_attachment_type_id_seq'::regclass);


--

-- Name: vocabulary_attachment_type vocabulary_attachment_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_attachment_type
    ADD CONSTRAINT vocabulary_attachment_type_pkey PRIMARY KEY (id);


--
