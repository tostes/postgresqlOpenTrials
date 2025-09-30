-- Data for Name: vocabulary_attachment_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_attachment_type VALUES (1, 'Approved Opinion', 'Parecer Aprovado', 'Opinión Aprobada', true);
INSERT INTO public.vocabulary_attachment_type VALUES (2, 'Other', 'Outro', 'Otro', true);


--

-- Name: vocabulary_attachment_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_attachment_type_id_seq', 1, false);


--
