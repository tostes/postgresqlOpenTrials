-- Data for Name: vocabulary_study_type_temporality; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_type_temporality VALUES (1, 'N/A', 'N/A', 'N/A', true);
INSERT INTO public.vocabulary_study_type_temporality VALUES (2, 'Prospective', 'Prospectivo', 'Futuro', true);
INSERT INTO public.vocabulary_study_type_temporality VALUES (3, 'Retrospective', 'Retrospectivo', 'Retrospectivo', true);
INSERT INTO public.vocabulary_study_type_temporality VALUES (4, 'Retrospective and Prospective', 'Retrospectivo e Prospectivo', 'Retrospectiva y Prospectiva', true);
INSERT INTO public.vocabulary_study_type_temporality VALUES (5, 'Transversal', 'Transversal', 'Transversal', true);
INSERT INTO public.vocabulary_study_type_temporality VALUES (6, 'Longitudinal', 'Longitudinal', 'Longitudinal', true);
INSERT INTO public.vocabulary_study_type_temporality VALUES (7, 'Other', 'Outro', 'Otro', true);


--

-- Name: vocabulary_study_type_temporality_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_temporality_id_seq', 1, false);


--
