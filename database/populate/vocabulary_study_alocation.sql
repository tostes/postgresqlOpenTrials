-- Data for Name: vocabulary_study_alocation; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_alocation VALUES (1, 'Non-randomized controlled', 'Controlado não randomizado', 'Controlado no aleatorio', true);
INSERT INTO public.vocabulary_study_alocation VALUES (2, 'Randomized Controlled', 'Randomizado Controlado', 'Controlado Aleatorio', true);
INSERT INTO public.vocabulary_study_alocation VALUES (3, 'Single Arm', 'Braço Único', 'Un Solo Brazo', true);
INSERT INTO public.vocabulary_study_alocation VALUES (4, 'N/A', 'N/A', 'N/A', true);


--

-- Name: vocabulary_study_alocation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_alocation_id_seq', 1, false);


--
