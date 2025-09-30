-- Name: track_trial_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.track_trial_status (
    id integer NOT NULL,
    trial_id integer NOT NULL,
    status integer NOT NULL,
    status_date timestamp without time zone DEFAULT now() NOT NULL,
    status_changer integer
);


--
-- Name: track_trial_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.track_trial_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: track_trial_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.track_trial_status_id_seq OWNED BY public.track_trial_status.id;


--
-- Name: track_trial_status id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.track_trial_status ALTER COLUMN id SET DEFAULT nextval('public.track_trial_status_id_seq'::regclass);


--
-- Name: track_trial_status track_trial_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.track_trial_status
    ADD CONSTRAINT track_trial_status_pkey PRIMARY KEY (id);


--
-- Name: track_trial_status track_trial_status_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.track_trial_status
    ADD CONSTRAINT track_trial_status_status_fkey FOREIGN KEY (status) REFERENCES public.vocabulary_recruitment_status(id);


--
-- Name: track_trial_status track_trial_status_status_changer_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.track_trial_status
    ADD CONSTRAINT track_trial_status_status_changer_fkey FOREIGN KEY (status_changer) REFERENCES public.research_institutions(id) ON DELETE SET NULL;


--
-- Name: track_trial_status track_trial_status_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.track_trial_status
    ADD CONSTRAINT track_trial_status_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id) ON DELETE CASCADE;

--
-- PostgreSQL database dump complete
--
