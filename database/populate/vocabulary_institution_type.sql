-- Data for Name: vocabulary_institution_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_institution_type VALUES (1, 'Clinical Research Network', 'Rede de Pesquisa Clínica', 'Rede de Pesquisa Clínica', true);
INSERT INTO public.vocabulary_institution_type VALUES (2, 'Federal Agency', 'Agência Federal', 'Agência Federal', true);
INSERT INTO public.vocabulary_institution_type VALUES (3, 'Industry', 'Indústria', 'Indústria', true);
INSERT INTO public.vocabulary_institution_type VALUES (4, 'Ministery of Health', 'Ministério da Saúde', 'Ministério da Saúde', true);
INSERT INTO public.vocabulary_institution_type VALUES (5, 'Non-governnamental Agency', 'Agência não governamental', 'Agência não governamental', true);
INSERT INTO public.vocabulary_institution_type VALUES (6, 'State Research Support Agency', 'Agência de Fomento à Pesquisa', 'Agência de Fomento à Pesquisa', true);
INSERT INTO public.vocabulary_institution_type VALUES (7, 'Higher Education Institution', 'Instituição de Ensino Superior', 'Instituição de Ensino Superior', true);
INSERT INTO public.vocabulary_institution_type VALUES (8, 'Other', 'Outro', 'Otro', true);


--

-- Name: vocabulary_institution_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_institution_type_id_seq', 1, false);


--
