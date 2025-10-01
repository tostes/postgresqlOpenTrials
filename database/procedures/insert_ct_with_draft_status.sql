-- Name: insert_ct_with_draft_status(...); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.insert_ct_with_draft_status(
    p_creator_id integer,
    p_register_id character varying,
    p_study_type integer,
    p_public_title character varying,
    p_public_title_native character varying,
    p_scientific_title character varying,
    p_scientific_title_native character varying,
    p_recruitment_status integer,
    p_completion_date date,
    p_trial_url character varying,
    p_responsible_user_id integer
) RETURNS integer
    LANGUAGE plpgsql
AS $$
DECLARE
    v_ct_id integer;
    v_draft_status_id integer;
BEGIN
    INSERT INTO public.ct (
        creator_id,
        register_id,
        study_type,
        public_title,
        public_title_native,
        scientific_title,
        scientific_title_native,
        recruitment_status,
        completion_date,
        trial_url
    )
    VALUES (
        p_creator_id,
        p_register_id,
        p_study_type,
        p_public_title,
        p_public_title_native,
        p_scientific_title,
        p_scientific_title_native,
        p_recruitment_status,
        p_completion_date,
        p_trial_url
    )
    RETURNING id INTO v_ct_id;

    SELECT id
    INTO v_draft_status_id
    FROM public.vocabulary_recruitment_status
    WHERE lower(choice_en) = 'draft'
    ORDER BY id
    LIMIT 1;

    IF v_draft_status_id IS NULL THEN
        RAISE EXCEPTION 'Draft status not configured in vocabulary_recruitment_status table.';
    END IF;

    INSERT INTO public.track_trial_status (
        trial_id,
        status,
        status_date,
        status_changer
    )
    VALUES (
        v_ct_id,
        v_draft_status_id,
        now(),
        p_responsible_user_id
    );

    RETURN v_ct_id;
END;
$$;


--
