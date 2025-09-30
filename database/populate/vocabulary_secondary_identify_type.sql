-- Data for Name: vocabulary_secondary_identify_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_secondary_identify_type VALUES (1, NULL, NULL, NULL, 'CAAE', 'CAAE', 'CAAE', true);
INSERT INTO public.vocabulary_secondary_identify_type VALUES (2, NULL, NULL, NULL, 'Universal Trial Number (UTN)', 'Número Universal de Ensaio Clínico (UTN)', 'Universal Trial Number (UTN)', true);
INSERT INTO public.vocabulary_secondary_identify_type VALUES (3, NULL, NULL, NULL, 'Research Ethics Committee', 'Comitê de Ética em Pesquisa (CEP)', 'Comité de Ética en Investigación', true);
INSERT INTO public.vocabulary_secondary_identify_type VALUES (4, NULL, NULL, NULL, 'Other', 'Outros', 'Otros', true);


--

-- Name: vocabulary_secondary_identify_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_secondary_identify_type_id_seq', 1, false);


--
