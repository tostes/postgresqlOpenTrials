-- Data for Name: vocabulary_study_type_purpose; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_type_purpose VALUES (1, 'Diagnostic', 'Diagnóstico', 'Diagnóstico', true);
INSERT INTO public.vocabulary_study_type_purpose VALUES (2, 'Etiological', 'Etiológico', 'Etiológico', true);
INSERT INTO public.vocabulary_study_type_purpose VALUES (3, 'Prognostic', 'Prognostico', 'Prognostico', true);
INSERT INTO public.vocabulary_study_type_purpose VALUES (4, 'Prevention', 'Prevenção', 'Prevención', true);
INSERT INTO public.vocabulary_study_type_purpose VALUES (5, 'Treatment', 'Tratamento', 'Tratamiento', true);
INSERT INTO public.vocabulary_study_type_purpose VALUES (6, 'Other', 'Outro', 'Otro', true);


--

-- Name: vocabulary_study_type_purpose_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_purpose_id_seq', 1, false);


--
