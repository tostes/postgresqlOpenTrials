-- Data for Name: vocabulary_recruitment_status; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_recruitment_status VALUES (1, 'Not yet recruiting', 'Ainda não recrutando', 'Aún no reclutando', true);
INSERT INTO public.vocabulary_recruitment_status VALUES (2, 'Recruiting', 'Recrutando', 'Reclutando', true);
INSERT INTO public.vocabulary_recruitment_status VALUES (3, 'Completed', 'Concluído', 'Completado', true);
INSERT INTO public.vocabulary_recruitment_status VALUES (4, 'Terminated', 'Encerrado', 'Terminado', true);


--

-- Name: vocabulary_recruitment_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_recruitment_status_id_seq', 4, true);


--
