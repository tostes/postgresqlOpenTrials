-- Data for Name: vocabulary_study_type_masking; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_type_masking VALUES (1, 'Open', 'Aberto', 'Abierto', true);
INSERT INTO public.vocabulary_study_type_masking VALUES (2, 'Single-blind', 'Cego', 'Ciego', true);
INSERT INTO public.vocabulary_study_type_masking VALUES (3, 'Double-blind', 'Duplo Cego', 'Doble Ciego', true);
INSERT INTO public.vocabulary_study_type_masking VALUES (4, 'Triple-blind', 'Triplo Cego', 'Triple Ciego', true);
INSERT INTO public.vocabulary_study_type_masking VALUES (5, 'N/A', 'N/A', 'N/A', true);


--

-- Name: vocabulary_study_type_masking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_masking_id_seq', 1, false);


--
