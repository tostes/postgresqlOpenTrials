-- Name: vocabulary_monetary_material_support_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_monetary_material_support_type (
    id integer NOT NULL,
    type_en character varying(255),
    type_pt character varying(255),
    type_es character varying(255),
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--

-- Name: vocabulary_monetary_material_support_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_monetary_material_support_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--

-- Name: vocabulary_monetary_material_support_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_monetary_material_support_type_id_seq OWNED BY public.vocabulary_monetary_material_support_type.id;


--

-- Name: vocabulary_monetary_material_support_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_monetary_material_support_type ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_monetary_material_support_type_id_seq'::regclass);


--

-- Name: vocabulary_monetary_material_support_type vocabulary_monetary_material_support_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_monetary_material_support_type
    ADD CONSTRAINT vocabulary_monetary_material_support_type_pkey PRIMARY KEY (id);


--
