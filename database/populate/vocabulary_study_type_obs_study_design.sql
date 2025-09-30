-- Data for Name: vocabulary_study_type_obs_study_design; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (1, 'Diagnosis', 'Diagnóstico', 'Diagnóstico', true);
INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (2, 'Etiological', 'Etiológico', 'Etiológico', true);
INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (3, 'Prognosis', 'Prognóstico', 'Prognóstico', true);
INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (4, 'Prevenção', 'Prevenção', 'Prevención', true);
INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (5, 'Treatment', 'Tratamento', 'Tratamiento', true);
INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (6, 'Other', 'Outro', 'Otro', true);


--

-- Name: vocabulary_study_type_obs_study_design_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_obs_study_design_id_seq', 1, false);


--
