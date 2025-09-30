--
-- PostgreSQL database dump
--

-- Dumped from database version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)
-- Dumped by pg_dump version 12.22 (Ubuntu 12.22-0ubuntu0.20.04.4)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: generate_register_code(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_register_code(prefix character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_code VARCHAR(30);
BEGIN
    LOOP
        -- Gerar um código aleatório
        new_code := prefix || '-' || substr(md5(random()::text || clock_timestamp()::text), 1, 6);

        -- Verificar se o código já existe na tabela ct
        EXIT WHEN NOT EXISTS (
            SELECT 1 FROM ct WHERE register_id ILIKE new_code
        );

        -- Se o código existir, gerar outro
    END LOOP;

    RETURN new_code;
END;
$$;


--
-- Name: get_full_trial_json_auto_multilang(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_full_trial_json_auto_multilang(p_ct_id integer) RETURNS jsonb
    LANGUAGE plpgsql
    AS $_$
DECLARE
    result JSONB := '{}'::jsonb;
    ct_data JSONB;
    rel RECORD;
    sub_data JSONB;
    sql_query TEXT;
BEGIN
    -- 1. Obter dados do CT principal com tradução de vocabulário
    SELECT jsonb_build_object(
        'id', c.id,
        'register_id', c.register_id,
        'public_title', c.public_title,
        'public_title_native', c.public_title_native,
        'scientific_title', c.scientific_title,
        'scientific_title_native', c.scientific_title_native,
        'completion_date', c.completion_date,
        'trial_url', c.trial_url,
        'study_type', jsonb_build_object(
            'id', vi.id,
            'pt', vi.choice_pt,
            'en', vi.choice_en
        ),
        'recruitment_status', jsonb_build_object(
            'id', vrs.id,
            'pt', vrs.choice_pt,
            'en', vrs.choice_en
        )
    )
    INTO ct_data
    FROM ct c
    LEFT JOIN vocabulary_intervention vi ON vi.id = c.study_type
    LEFT JOIN vocabulary_recruitment_status vrs ON vrs.id = c.recruitment_status
    WHERE c.id = p_ct_id;

    -- 2. Adiciona o CT ao resultado
    result := jsonb_build_object('ct', ct_data);

    -- 3. Descobre todas as tabelas que se relacionam com ct(trial_id)
    FOR rel IN
        SELECT tc.table_name
        FROM information_schema.table_constraints tc
        JOIN information_schema.key_column_usage kcu
            ON tc.constraint_name = kcu.constraint_name
        WHERE tc.constraint_type = 'FOREIGN KEY'
            AND kcu.column_name = 'trial_id'
            AND tc.table_schema = 'public'
            AND tc.table_name != 'ct'
    LOOP
        -- 4. Monta consulta dinâmica simples para pegar os registros relacionados
        sql_query := format(
            'SELECT jsonb_agg(to_jsonb(t)) FROM %I t WHERE trial_id = $1',
            rel.table_name
        );

        EXECUTE sql_query INTO sub_data USING p_ct_id;

        IF sub_data IS NULL THEN
            sub_data := '[]'::jsonb;
        END IF;

        -- 5. Adiciona ao resultado
        result := result || jsonb_build_object(rel.table_name, sub_data);
    END LOOP;

    RETURN result;
END;
$_$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: ct; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct (
    id integer NOT NULL,
    creator_id integer,
    register_id character varying(100),
    study_type integer,
    public_title character varying(255) NOT NULL,
    public_title_native character varying(255) NOT NULL,
    scientific_title character varying(255) NOT NULL,
    scientific_title_native character varying(255) NOT NULL,
    recruitment_status integer,
    completion_date date,
    trial_url character varying(255)
);


--
-- Name: ct_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_attachments (
    id integer NOT NULL,
    trial_id integer,
    attachment_type integer,
    is_public boolean DEFAULT false,
    attachment_link character varying(255),
    attachment character varying(255)
);


--
-- Name: ct_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_attachments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_attachments_id_seq OWNED BY public.ct_attachments.id;


--
-- Name: ct_contact; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_contact (
    id integer NOT NULL,
    trial_id integer,
    first_name character varying(255),
    middle_name character varying(255),
    last_name character varying(255),
    address text,
    city character varying(100),
    country character varying(100),
    zip_code character varying(20),
    telephone character varying(50),
    email character varying(255),
    affiliation integer,
    is_public_contact boolean DEFAULT false,
    is_scientific_contact boolean DEFAULT false,
    is_site_contact boolean DEFAULT false,
    is_ethic_contact boolean DEFAULT false
);


--
-- Name: ct_contact_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_contact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_contact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_contact_id_seq OWNED BY public.ct_contact.id;


--
-- Name: ct_country_of_recruitment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_country_of_recruitment (
    id integer NOT NULL,
    trial_id integer,
    country character varying(100)
);


--
-- Name: ct_country_of_recruitment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_country_of_recruitment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_country_of_recruitment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_country_of_recruitment_id_seq OWNED BY public.ct_country_of_recruitment.id;


--
-- Name: ct_data_sharing; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_data_sharing (
    id integer NOT NULL,
    trial_id integer,
    data_sharing_plan integer,
    data_sharing_description text,
    data_sharing_description_native text
);


--
-- Name: ct_data_sharing_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_data_sharing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_data_sharing_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_data_sharing_id_seq OWNED BY public.ct_data_sharing.id;


--
-- Name: ct_editor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_editor (
    id integer NOT NULL,
    owner_id integer,
    trial_id integer,
    editor_id integer
);


--
-- Name: ct_editor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_editor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_editor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_editor_id_seq OWNED BY public.ct_editor.id;


--
-- Name: ct_health_condition_problem_study; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_health_condition_problem_study (
    id integer NOT NULL,
    trial_id integer,
    health_condition text,
    health_condition_native text,
    health_condition_code character varying(255),
    health_condition_code_type integer,
    health_condition_code_vocabulary integer,
    health_condition_keyword character varying(255)
);


--
-- Name: ct_health_condition_problem_study_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_health_condition_problem_study_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_health_condition_problem_study_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_health_condition_problem_study_id_seq OWNED BY public.ct_health_condition_problem_study.id;


--
-- Name: ct_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_id_seq OWNED BY public.ct.id;


--
-- Name: ct_institutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_institutions (
    id integer NOT NULL,
    trial_id integer,
    name character varying(255),
    address text,
    city character varying(255),
    state character varying(255),
    country integer,
    type_id integer
);


--
-- Name: ct_institutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_institutions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_institutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_institutions_id_seq OWNED BY public.ct_institutions.id;


--
-- Name: ct_intervention; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_intervention (
    id integer NOT NULL,
    trial_id integer,
    intervention_description text,
    intervention_description_pt text,
    is_drug boolean DEFAULT false,
    is_device boolean DEFAULT false,
    is_biological_vacina boolean DEFAULT false,
    is_procedure_surgery boolean DEFAULT false,
    is_radiation boolean DEFAULT false,
    is_behavioural boolean DEFAULT false,
    is_genetics boolean DEFAULT false,
    is_diatary_supplement boolean DEFAULT false,
    is_other boolean DEFAULT false
);


--
-- Name: ct_intervention_descriptor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_intervention_descriptor (
    id integer NOT NULL,
    trial_id integer,
    intervention_descriptor_type integer,
    intervention_descriptor_vocabulary integer,
    intervention_descriptor_code character varying(255),
    intervention_descriptor character varying(255),
    intervention_descriptor_pt character varying(255)
);


--
-- Name: ct_intervention_descriptor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_intervention_descriptor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_intervention_descriptor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_intervention_descriptor_id_seq OWNED BY public.ct_intervention_descriptor.id;


--
-- Name: ct_intervention_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_intervention_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_intervention_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_intervention_id_seq OWNED BY public.ct_intervention.id;


--
-- Name: ct_outcome; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_outcome (
    id integer NOT NULL,
    trial_id integer,
    outcome_type integer,
    outcome_name character varying(255),
    time_point character varying(255),
    measure character varying(255),
    objectives character varying(255),
    endpoints character varying(255),
    description text,
    description_native text
);


--
-- Name: ct_outcome_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_outcome_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_outcome_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_outcome_id_seq OWNED BY public.ct_outcome.id;


--
-- Name: ct_recruitment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_recruitment (
    id integer NOT NULL,
    trial_id integer,
    first_date_enrollment date,
    last_date_enrollment date,
    target_sample_size integer,
    inclusion_criteria text,
    inclusion_criteria_native text,
    exclusion_criteria text,
    exclusion_criteria_native text,
    age_minimum integer,
    unit_age_minimum character varying(50),
    age_maximum integer,
    unit_age_maximum character varying(50)
);


--
-- Name: ct_recruitment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_recruitment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_recruitment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_recruitment_id_seq OWNED BY public.ct_recruitment.id;


--
-- Name: ct_results; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_results (
    id integer NOT NULL,
    trial_id integer,
    publication_date date,
    results_url character varying(255),
    baseline text,
    baseline_native text,
    participants_flow text,
    participants_flow_native text,
    adverse_events text,
    adverse_events_native text,
    outcome_mesure text,
    outcome_mesure_native text,
    protocol_url character varying(255),
    sumary_results text,
    sumary_results_native text
);


--
-- Name: ct_results_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_results_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_results_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_results_id_seq OWNED BY public.ct_results.id;


--
-- Name: ct_secondary_identify_numbers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_secondary_identify_numbers (
    id integer NOT NULL,
    trial_id integer,
    identify_type integer,
    identify_code character varying(255),
    issuing_institution character varying(255)
);


--
-- Name: ct_secondary_identify_numbers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_secondary_identify_numbers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_secondary_identify_numbers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_secondary_identify_numbers_id_seq OWNED BY public.ct_secondary_identify_numbers.id;


--
-- Name: ct_source_monetary_material_support; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_source_monetary_material_support (
    id integer NOT NULL,
    trial_id integer,
    source_name character varying(255),
    source_type character varying(255),
    support_type integer
);


--
-- Name: ct_source_monetary_material_support_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_source_monetary_material_support_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_source_monetary_material_support_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_source_monetary_material_support_id_seq OWNED BY public.ct_source_monetary_material_support.id;


--
-- Name: ct_sponsor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_sponsor (
    id integer NOT NULL,
    trial_id integer,
    institution_id integer,
    is_primary_sponsor boolean DEFAULT false,
    is_secondary_sponsor boolean DEFAULT false,
    is_monetary_support boolean DEFAULT false,
    source_type character varying(255)
);


--
-- Name: ct_sponsor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_sponsor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_sponsor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_sponsor_id_seq OWNED BY public.ct_sponsor.id;


--
-- Name: ct_study_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ct_study_type (
    id integer NOT NULL,
    trial_id integer,
    expanded_access_program integer,
    purpose integer,
    intervention_assignment integer,
    number_of_arms integer,
    masking_type integer,
    alocation_type integer,
    study_phase integer,
    observational_study_design integer,
    temporality integer
);


--
-- Name: ct_study_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ct_study_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ct_study_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ct_study_type_id_seq OWNED BY public.ct_study_type.id;


--
-- Name: research_institutions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.research_institutions (
    id integer NOT NULL,
    name character varying(255),
    address text,
    city character varying(255),
    state character varying(255),
    country_id integer,
    type_id integer,
    approved boolean DEFAULT false
);


--
-- Name: research_institutions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.research_institutions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: research_institutions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.research_institutions_id_seq OWNED BY public.research_institutions.id;


--
-- Name: vocabulary_attachment_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_attachment_type (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_attachment_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_attachment_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_attachment_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_attachment_type_id_seq OWNED BY public.vocabulary_attachment_type.id;


--
-- Name: vocabulary_country; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_country (
    id integer NOT NULL,
    country_en character varying(255),
    country_pt character varying(255),
    country_es character varying(255),
    country_label character varying(255)
);


--
-- Name: vocabulary_country_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_country_id_seq OWNED BY public.vocabulary_country.id;


--
-- Name: vocabulary_data_sharing_plan; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_data_sharing_plan (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_data_sharing_plan_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_data_sharing_plan_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_data_sharing_plan_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_data_sharing_plan_id_seq OWNED BY public.vocabulary_data_sharing_plan.id;


--
-- Name: vocabulary_health_condition_code_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_health_condition_code_type (
    id integer NOT NULL,
    code_type_en character varying(255),
    code_type_pt character varying(255),
    code_type_es character varying(255),
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_health_condition_code_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_health_condition_code_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_health_condition_code_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_health_condition_code_type_id_seq OWNED BY public.vocabulary_health_condition_code_type.id;


--
-- Name: vocabulary_health_condition_code_vocabulary; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_health_condition_code_vocabulary (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_health_condition_code_vocabulary_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_health_condition_code_vocabulary_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_health_condition_code_vocabulary_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_health_condition_code_vocabulary_id_seq OWNED BY public.vocabulary_health_condition_code_vocabulary.id;


--
-- Name: vocabulary_institution; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_institution (
    id integer NOT NULL,
    name character varying(255),
    address text,
    state character varying(255),
    city character varying(255),
    country character varying(255),
    institution_type character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_institution_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_institution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_institution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_institution_id_seq OWNED BY public.vocabulary_institution.id;


--
-- Name: vocabulary_institution_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_institution_type (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_institution_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_institution_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_institution_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_institution_type_id_seq OWNED BY public.vocabulary_institution_type.id;


--
-- Name: vocabulary_intervention; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_intervention (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_intervention_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_intervention_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_intervention_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_intervention_id_seq OWNED BY public.vocabulary_intervention.id;


--
-- Name: vocabulary_monetary_material_support_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_monetary_material_support_type (
    id integer NOT NULL,
    type_en character varying(255),
    type_pt character varying(255),
    type_es character varying(255),
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_monetary_material_support_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_monetary_material_support_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_monetary_material_support_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_monetary_material_support_type_id_seq OWNED BY public.vocabulary_monetary_material_support_type.id;


--
-- Name: vocabulary_outcome_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_outcome_type (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_outcome_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_outcome_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_outcome_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_outcome_type_id_seq OWNED BY public.vocabulary_outcome_type.id;


--
-- Name: vocabulary_recruitment_age_unit; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_recruitment_age_unit (
    id integer NOT NULL,
    value character varying(50),
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_recruitment_age_unit_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_recruitment_age_unit_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_recruitment_age_unit_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_recruitment_age_unit_id_seq OWNED BY public.vocabulary_recruitment_age_unit.id;


--
-- Name: vocabulary_recruitment_status; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_recruitment_status (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_recruitment_status_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_recruitment_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_recruitment_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_recruitment_status_id_seq OWNED BY public.vocabulary_recruitment_status.id;


--
-- Name: vocabulary_secondary_identify_type; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_secondary_identify_type (
    id integer NOT NULL,
    type_en character varying(255),
    type_pt character varying(255),
    type_es character varying(255),
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_secondary_identify_type_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_secondary_identify_type_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_secondary_identify_type_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_secondary_identify_type_id_seq OWNED BY public.vocabulary_secondary_identify_type.id;


--
-- Name: vocabulary_study_alocation; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_study_alocation (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_study_alocation_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_study_alocation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_study_alocation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_study_alocation_id_seq OWNED BY public.vocabulary_study_alocation.id;


--
-- Name: vocabulary_study_type_expanded_access; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_study_type_expanded_access (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_study_type_expanded_access_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_study_type_expanded_access_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_study_type_expanded_access_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_study_type_expanded_access_id_seq OWNED BY public.vocabulary_study_type_expanded_access.id;


--
-- Name: vocabulary_study_type_intervention_assignment; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_study_type_intervention_assignment (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_study_type_intervention_assignment_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_study_type_intervention_assignment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_study_type_intervention_assignment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_study_type_intervention_assignment_id_seq OWNED BY public.vocabulary_study_type_intervention_assignment.id;


--
-- Name: vocabulary_study_type_masking; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_study_type_masking (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_study_type_masking_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_study_type_masking_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_study_type_masking_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_study_type_masking_id_seq OWNED BY public.vocabulary_study_type_masking.id;


--
-- Name: vocabulary_study_type_obs_study_design; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_study_type_obs_study_design (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_study_type_obs_study_design_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_study_type_obs_study_design_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_study_type_obs_study_design_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_study_type_obs_study_design_id_seq OWNED BY public.vocabulary_study_type_obs_study_design.id;


--
-- Name: vocabulary_study_type_phase; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_study_type_phase (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_study_type_phase_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_study_type_phase_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_study_type_phase_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_study_type_phase_id_seq OWNED BY public.vocabulary_study_type_phase.id;


--
-- Name: vocabulary_study_type_purpose; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_study_type_purpose (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_study_type_purpose_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_study_type_purpose_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_study_type_purpose_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_study_type_purpose_id_seq OWNED BY public.vocabulary_study_type_purpose.id;


--
-- Name: vocabulary_study_type_temporality; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vocabulary_study_type_temporality (
    id integer NOT NULL,
    choice_en character varying(255),
    choice_pt character varying(255),
    choice_es character varying(255),
    is_active boolean DEFAULT true
);


--
-- Name: vocabulary_study_type_temporality_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vocabulary_study_type_temporality_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vocabulary_study_type_temporality_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vocabulary_study_type_temporality_id_seq OWNED BY public.vocabulary_study_type_temporality.id;


--
-- Name: ct id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct ALTER COLUMN id SET DEFAULT nextval('public.ct_id_seq'::regclass);


--
-- Name: ct_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_attachments ALTER COLUMN id SET DEFAULT nextval('public.ct_attachments_id_seq'::regclass);


--
-- Name: ct_contact id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_contact ALTER COLUMN id SET DEFAULT nextval('public.ct_contact_id_seq'::regclass);


--
-- Name: ct_country_of_recruitment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_country_of_recruitment ALTER COLUMN id SET DEFAULT nextval('public.ct_country_of_recruitment_id_seq'::regclass);


--
-- Name: ct_data_sharing id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_data_sharing ALTER COLUMN id SET DEFAULT nextval('public.ct_data_sharing_id_seq'::regclass);


--
-- Name: ct_editor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_editor ALTER COLUMN id SET DEFAULT nextval('public.ct_editor_id_seq'::regclass);


--
-- Name: ct_health_condition_problem_study id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_health_condition_problem_study ALTER COLUMN id SET DEFAULT nextval('public.ct_health_condition_problem_study_id_seq'::regclass);


--
-- Name: ct_institutions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_institutions ALTER COLUMN id SET DEFAULT nextval('public.ct_institutions_id_seq'::regclass);


--
-- Name: ct_intervention id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention ALTER COLUMN id SET DEFAULT nextval('public.ct_intervention_id_seq'::regclass);


--
-- Name: ct_intervention_descriptor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention_descriptor ALTER COLUMN id SET DEFAULT nextval('public.ct_intervention_descriptor_id_seq'::regclass);


--
-- Name: ct_outcome id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_outcome ALTER COLUMN id SET DEFAULT nextval('public.ct_outcome_id_seq'::regclass);


--
-- Name: ct_recruitment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_recruitment ALTER COLUMN id SET DEFAULT nextval('public.ct_recruitment_id_seq'::regclass);


--
-- Name: ct_results id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_results ALTER COLUMN id SET DEFAULT nextval('public.ct_results_id_seq'::regclass);


--
-- Name: ct_secondary_identify_numbers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_secondary_identify_numbers ALTER COLUMN id SET DEFAULT nextval('public.ct_secondary_identify_numbers_id_seq'::regclass);


--
-- Name: ct_source_monetary_material_support id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_source_monetary_material_support ALTER COLUMN id SET DEFAULT nextval('public.ct_source_monetary_material_support_id_seq'::regclass);


--
-- Name: ct_sponsor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_sponsor ALTER COLUMN id SET DEFAULT nextval('public.ct_sponsor_id_seq'::regclass);


--
-- Name: ct_study_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type ALTER COLUMN id SET DEFAULT nextval('public.ct_study_type_id_seq'::regclass);


--
-- Name: research_institutions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.research_institutions ALTER COLUMN id SET DEFAULT nextval('public.research_institutions_id_seq'::regclass);


--
-- Name: vocabulary_attachment_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_attachment_type ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_attachment_type_id_seq'::regclass);


--
-- Name: vocabulary_country id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_country ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_country_id_seq'::regclass);


--
-- Name: vocabulary_data_sharing_plan id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_data_sharing_plan ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_data_sharing_plan_id_seq'::regclass);


--
-- Name: vocabulary_health_condition_code_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_health_condition_code_type ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_health_condition_code_type_id_seq'::regclass);


--
-- Name: vocabulary_health_condition_code_vocabulary id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_health_condition_code_vocabulary ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_health_condition_code_vocabulary_id_seq'::regclass);


--
-- Name: vocabulary_institution id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_institution ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_institution_id_seq'::regclass);


--
-- Name: vocabulary_institution_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_institution_type ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_institution_type_id_seq'::regclass);


--
-- Name: vocabulary_intervention id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_intervention ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_intervention_id_seq'::regclass);


--
-- Name: vocabulary_monetary_material_support_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_monetary_material_support_type ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_monetary_material_support_type_id_seq'::regclass);


--
-- Name: vocabulary_outcome_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_outcome_type ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_outcome_type_id_seq'::regclass);


--
-- Name: vocabulary_recruitment_age_unit id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_recruitment_age_unit ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_recruitment_age_unit_id_seq'::regclass);


--
-- Name: vocabulary_recruitment_status id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_recruitment_status ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_recruitment_status_id_seq'::regclass);


--
-- Name: vocabulary_secondary_identify_type id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_secondary_identify_type ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_secondary_identify_type_id_seq'::regclass);


--
-- Name: vocabulary_study_alocation id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_alocation ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_study_alocation_id_seq'::regclass);


--
-- Name: vocabulary_study_type_expanded_access id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_expanded_access ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_study_type_expanded_access_id_seq'::regclass);


--
-- Name: vocabulary_study_type_intervention_assignment id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_intervention_assignment ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_study_type_intervention_assignment_id_seq'::regclass);


--
-- Name: vocabulary_study_type_masking id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_masking ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_study_type_masking_id_seq'::regclass);


--
-- Name: vocabulary_study_type_obs_study_design id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_obs_study_design ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_study_type_obs_study_design_id_seq'::regclass);


--
-- Name: vocabulary_study_type_phase id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_phase ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_study_type_phase_id_seq'::regclass);


--
-- Name: vocabulary_study_type_purpose id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_purpose ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_study_type_purpose_id_seq'::regclass);


--
-- Name: vocabulary_study_type_temporality id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_temporality ALTER COLUMN id SET DEFAULT nextval('public.vocabulary_study_type_temporality_id_seq'::regclass);


--
-- Data for Name: ct; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.ct VALUES (3, NULL, 'CT001', 1, 'Estudo de teste', 'Estudo de teste', 'Estudo científico de teste', 'Estudo científico de teste', 1, '2025-01-01', 'https://example.com/ct001');


--
-- Data for Name: ct_attachments; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_contact; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_country_of_recruitment; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_data_sharing; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_editor; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_health_condition_problem_study; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_institutions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_intervention; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_intervention_descriptor; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_outcome; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_recruitment; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_results; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_secondary_identify_numbers; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_source_monetary_material_support; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_sponsor; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: ct_study_type; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: research_institutions; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vocabulary_attachment_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_attachment_type VALUES (1, 'Approved Opinion', 'Parecer Aprovado', 'Opinión Aprobada', true);
INSERT INTO public.vocabulary_attachment_type VALUES (2, 'Other', 'Outro', 'Otro', true);


--
-- Data for Name: vocabulary_country; Type: TABLE DATA; Schema: public; Owner: -
--



--
-- Data for Name: vocabulary_data_sharing_plan; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_data_sharing_plan VALUES (1, 'Yes', 'Sim', 'Si', true);
INSERT INTO public.vocabulary_data_sharing_plan VALUES (2, 'No', 'Não', 'No', true);


--
-- Data for Name: vocabulary_health_condition_code_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_health_condition_code_type VALUES (1, NULL, NULL, NULL, 'general', 'geral', 'geral', true);
INSERT INTO public.vocabulary_health_condition_code_type VALUES (2, NULL, NULL, NULL, 'specific', 'especifico', 'especifico', true);


--
-- Data for Name: vocabulary_health_condition_code_vocabulary; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_health_condition_code_vocabulary VALUES (1, 'CID-10', NULL, NULL, true);
INSERT INTO public.vocabulary_health_condition_code_vocabulary VALUES (2, 'DeCS', NULL, NULL, true);


--
-- Data for Name: vocabulary_institution; Type: TABLE DATA; Schema: public; Owner: -
--



--
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
-- Data for Name: vocabulary_intervention; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_intervention VALUES (1, 'Interventional', 'Intervencional', 'Intervencional', true);
INSERT INTO public.vocabulary_intervention VALUES (2, 'Observational', 'Observacional', 'Observacional', true);


--
-- Data for Name: vocabulary_monetary_material_support_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_monetary_material_support_type VALUES (13, NULL, NULL, NULL, 'funding agency', 'agencia de fomento', 'agencia fundadora', true);
INSERT INTO public.vocabulary_monetary_material_support_type VALUES (14, NULL, NULL, NULL, 'foundation', 'fundação', 'fundação', true);
INSERT INTO public.vocabulary_monetary_material_support_type VALUES (15, NULL, NULL, NULL, 'company', 'empresa', 'empresa', true);
INSERT INTO public.vocabulary_monetary_material_support_type VALUES (16, NULL, NULL, NULL, 'institution', 'instituição', 'institución', true);


--
-- Data for Name: vocabulary_outcome_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_outcome_type VALUES (1, 'Primary', 'Primário', 'Primario', true);
INSERT INTO public.vocabulary_outcome_type VALUES (2, 'Secondary', 'Secundário', 'Secundario', true);


--
-- Data for Name: vocabulary_recruitment_age_unit; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_recruitment_age_unit VALUES (1, 'Y', 'Year', 'Ano', 'Año', true);
INSERT INTO public.vocabulary_recruitment_age_unit VALUES (2, 'M', 'Month', 'Mês', 'Mes', true);


--
-- Data for Name: vocabulary_recruitment_status; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_recruitment_status VALUES (1, 'Not yet recruiting', 'Ainda não recrutando', 'Aún no reclutando', true);
INSERT INTO public.vocabulary_recruitment_status VALUES (2, 'Recruiting', 'Recrutando', 'Reclutando', true);
INSERT INTO public.vocabulary_recruitment_status VALUES (3, 'Completed', 'Concluído', 'Completado', true);
INSERT INTO public.vocabulary_recruitment_status VALUES (4, 'Terminated', 'Encerrado', 'Terminado', true);


--
-- Data for Name: vocabulary_secondary_identify_type; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_secondary_identify_type VALUES (1, NULL, NULL, NULL, 'CAAE', 'CAAE', 'CAAE', true);
INSERT INTO public.vocabulary_secondary_identify_type VALUES (2, NULL, NULL, NULL, 'Universal Trial Number (UTN)', 'Número Universal de Ensaio Clínico (UTN)', 'Universal Trial Number (UTN)', true);
INSERT INTO public.vocabulary_secondary_identify_type VALUES (3, NULL, NULL, NULL, 'Research Ethics Committee', 'Comitê de Ética em Pesquisa (CEP)', 'Comité de Ética en Investigación', true);
INSERT INTO public.vocabulary_secondary_identify_type VALUES (4, NULL, NULL, NULL, 'Other', 'Outros', 'Otros', true);


--
-- Data for Name: vocabulary_study_alocation; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_alocation VALUES (1, 'Non-randomized controlled', 'Controlado não randomizado', 'Controlado no aleatorio', true);
INSERT INTO public.vocabulary_study_alocation VALUES (2, 'Randomized Controlled', 'Randomizado Controlado', 'Controlado Aleatorio', true);
INSERT INTO public.vocabulary_study_alocation VALUES (3, 'Single Arm', 'Braço Único', 'Un Solo Brazo', true);
INSERT INTO public.vocabulary_study_alocation VALUES (4, 'N/A', 'N/A', 'N/A', true);


--
-- Data for Name: vocabulary_study_type_expanded_access; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_type_expanded_access VALUES (1, 'Unknown', 'Desconhecido', 'Desconocido', true);
INSERT INTO public.vocabulary_study_type_expanded_access VALUES (2, 'Yes', 'Sim', 'Si', true);
INSERT INTO public.vocabulary_study_type_expanded_access VALUES (3, 'No', 'Não', 'No', true);


--
-- Data for Name: vocabulary_study_type_intervention_assignment; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_type_intervention_assignment VALUES (1, 'Single Group', 'Grupo Único', 'Grupo Único', true);
INSERT INTO public.vocabulary_study_type_intervention_assignment VALUES (2, 'Parallel', 'Paralelo', 'Paralelo', true);
INSERT INTO public.vocabulary_study_type_intervention_assignment VALUES (3, 'Crusader', 'Cruzado', 'Cruzado', true);
INSERT INTO public.vocabulary_study_type_intervention_assignment VALUES (4, 'Factorial', 'Fatorial', 'Factorial', true);
INSERT INTO public.vocabulary_study_type_intervention_assignment VALUES (5, 'Other', 'Outros', 'Otros', true);


--
-- Data for Name: vocabulary_study_type_masking; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_type_masking VALUES (1, 'Open', 'Aberto', 'Abierto', true);
INSERT INTO public.vocabulary_study_type_masking VALUES (2, 'Single-blind', 'Cego', 'Ciego', true);
INSERT INTO public.vocabulary_study_type_masking VALUES (3, 'Double-blind', 'Duplo Cego', 'Doble Ciego', true);
INSERT INTO public.vocabulary_study_type_masking VALUES (4, 'Triple-blind', 'Triplo Cego', 'Triple Ciego', true);
INSERT INTO public.vocabulary_study_type_masking VALUES (5, 'N/A', 'N/A', 'N/A', true);


--
-- Data for Name: vocabulary_study_type_obs_study_design; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (1, 'Diagnosis', 'Diagnóstico', 'Diagnóstico', true);
INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (2, 'Etiological', 'Etiológico', 'Etiológico', true);
INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (3, 'Prognosis', 'Prognóstico', 'Prognóstico', true);
INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (4, 'Prevenção', 'Prevenção', 'Prevención', true);
INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (5, 'Treatment', 'Tratamento', 'Tratamiento', true);
INSERT INTO public.vocabulary_study_type_obs_study_design VALUES (6, 'Other', 'Outro', 'Otro', true);


--
-- Data for Name: vocabulary_study_type_phase; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_type_phase VALUES (1, 'N/A', 'N/A', 'N/A', true);
INSERT INTO public.vocabulary_study_type_phase VALUES (2, '1', '1', '1', true);
INSERT INTO public.vocabulary_study_type_phase VALUES (3, '1-2', '1-2', '1-2', true);
INSERT INTO public.vocabulary_study_type_phase VALUES (4, '2', '2', '2', true);
INSERT INTO public.vocabulary_study_type_phase VALUES (5, '2-3', '2-3', '2-3', true);
INSERT INTO public.vocabulary_study_type_phase VALUES (6, '3', '3', '3', true);
INSERT INTO public.vocabulary_study_type_phase VALUES (7, '4', '4', '4', true);
INSERT INTO public.vocabulary_study_type_phase VALUES (8, '0', '0', '0', true);


--
-- Data for Name: vocabulary_study_type_purpose; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.vocabulary_study_type_purpose VALUES (1, 'Diagnostic', 'Diagnóstico', 'Diagnóstico', true);
INSERT INTO public.vocabulary_study_type_purpose VALUES (2, 'Etiological', 'Etiológico', 'Etiológico', true);
INSERT INTO public.vocabulary_study_type_purpose VALUES (3, 'Prognostic', 'Prognostico', 'Prognostico', true);
INSERT INTO public.vocabulary_study_type_purpose VALUES (4, 'Prevention', 'Prevenção', 'Prevención', true);
INSERT INTO public.vocabulary_study_type_purpose VALUES (5, 'Treatment', 'Tratamento', 'Tratamiento', true);
INSERT INTO public.vocabulary_study_type_purpose VALUES (6, 'Other', 'Outro', 'Otro', true);


--
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
-- Name: ct_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_attachments_id_seq', 1, false);


--
-- Name: ct_contact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_contact_id_seq', 1, true);


--
-- Name: ct_country_of_recruitment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_country_of_recruitment_id_seq', 1, false);


--
-- Name: ct_data_sharing_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_data_sharing_id_seq', 1, false);


--
-- Name: ct_editor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_editor_id_seq', 1, false);


--
-- Name: ct_health_condition_problem_study_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_health_condition_problem_study_id_seq', 1, false);


--
-- Name: ct_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_id_seq', 3, true);


--
-- Name: ct_institutions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_institutions_id_seq', 1, false);


--
-- Name: ct_intervention_descriptor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_intervention_descriptor_id_seq', 1, false);


--
-- Name: ct_intervention_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_intervention_id_seq', 1, false);


--
-- Name: ct_outcome_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_outcome_id_seq', 1, false);


--
-- Name: ct_recruitment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_recruitment_id_seq', 1, false);


--
-- Name: ct_results_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_results_id_seq', 1, false);


--
-- Name: ct_secondary_identify_numbers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_secondary_identify_numbers_id_seq', 1, false);


--
-- Name: ct_source_monetary_material_support_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_source_monetary_material_support_id_seq', 1, false);


--
-- Name: ct_sponsor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_sponsor_id_seq', 1, false);


--
-- Name: ct_study_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ct_study_type_id_seq', 1, false);


--
-- Name: research_institutions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.research_institutions_id_seq', 1, false);


--
-- Name: vocabulary_attachment_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_attachment_type_id_seq', 1, false);


--
-- Name: vocabulary_country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_country_id_seq', 1, false);


--
-- Name: vocabulary_data_sharing_plan_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_data_sharing_plan_id_seq', 1, false);


--
-- Name: vocabulary_health_condition_code_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_health_condition_code_type_id_seq', 1, false);


--
-- Name: vocabulary_health_condition_code_vocabulary_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_health_condition_code_vocabulary_id_seq', 1, false);


--
-- Name: vocabulary_institution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_institution_id_seq', 1, false);


--
-- Name: vocabulary_institution_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_institution_type_id_seq', 1, false);


--
-- Name: vocabulary_intervention_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_intervention_id_seq', 1, true);


--
-- Name: vocabulary_monetary_material_support_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_monetary_material_support_type_id_seq', 16, true);


--
-- Name: vocabulary_outcome_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_outcome_type_id_seq', 1, false);


--
-- Name: vocabulary_recruitment_age_unit_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_recruitment_age_unit_id_seq', 1, false);


--
-- Name: vocabulary_recruitment_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_recruitment_status_id_seq', 4, true);


--
-- Name: vocabulary_secondary_identify_type_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_secondary_identify_type_id_seq', 1, false);


--
-- Name: vocabulary_study_alocation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_alocation_id_seq', 1, false);


--
-- Name: vocabulary_study_type_expanded_access_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_expanded_access_id_seq', 1, false);


--
-- Name: vocabulary_study_type_intervention_assignment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_intervention_assignment_id_seq', 1, false);


--
-- Name: vocabulary_study_type_masking_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_masking_id_seq', 1, false);


--
-- Name: vocabulary_study_type_obs_study_design_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_obs_study_design_id_seq', 1, false);


--
-- Name: vocabulary_study_type_phase_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_phase_id_seq', 1, false);


--
-- Name: vocabulary_study_type_purpose_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_purpose_id_seq', 1, false);


--
-- Name: vocabulary_study_type_temporality_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vocabulary_study_type_temporality_id_seq', 1, false);


--
-- Name: ct_attachments ct_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_attachments
    ADD CONSTRAINT ct_attachments_pkey PRIMARY KEY (id);


--
-- Name: ct_contact ct_contact_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_contact
    ADD CONSTRAINT ct_contact_pkey PRIMARY KEY (id);


--
-- Name: ct_country_of_recruitment ct_country_of_recruitment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_country_of_recruitment
    ADD CONSTRAINT ct_country_of_recruitment_pkey PRIMARY KEY (id);


--
-- Name: ct_data_sharing ct_data_sharing_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_data_sharing
    ADD CONSTRAINT ct_data_sharing_pkey PRIMARY KEY (id);


--
-- Name: ct_editor ct_editor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_editor
    ADD CONSTRAINT ct_editor_pkey PRIMARY KEY (id);


--
-- Name: ct_health_condition_problem_study ct_health_condition_problem_study_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_health_condition_problem_study
    ADD CONSTRAINT ct_health_condition_problem_study_pkey PRIMARY KEY (id);


--
-- Name: ct_institutions ct_institutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_institutions
    ADD CONSTRAINT ct_institutions_pkey PRIMARY KEY (id);


--
-- Name: ct_intervention_descriptor ct_intervention_descriptor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention_descriptor
    ADD CONSTRAINT ct_intervention_descriptor_pkey PRIMARY KEY (id);


--
-- Name: ct_intervention ct_intervention_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention
    ADD CONSTRAINT ct_intervention_pkey PRIMARY KEY (id);


--
-- Name: ct_outcome ct_outcome_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_outcome
    ADD CONSTRAINT ct_outcome_pkey PRIMARY KEY (id);


--
-- Name: ct ct_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct
    ADD CONSTRAINT ct_pkey PRIMARY KEY (id);


--
-- Name: ct_recruitment ct_recruitment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_recruitment
    ADD CONSTRAINT ct_recruitment_pkey PRIMARY KEY (id);


--
-- Name: ct_results ct_results_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_results
    ADD CONSTRAINT ct_results_pkey PRIMARY KEY (id);


--
-- Name: ct_secondary_identify_numbers ct_secondary_identify_numbers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_secondary_identify_numbers
    ADD CONSTRAINT ct_secondary_identify_numbers_pkey PRIMARY KEY (id);


--
-- Name: ct_source_monetary_material_support ct_source_monetary_material_support_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_source_monetary_material_support
    ADD CONSTRAINT ct_source_monetary_material_support_pkey PRIMARY KEY (id);


--
-- Name: ct_sponsor ct_sponsor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_sponsor
    ADD CONSTRAINT ct_sponsor_pkey PRIMARY KEY (id);


--
-- Name: ct_study_type ct_study_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_pkey PRIMARY KEY (id);


--
-- Name: research_institutions research_institutions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.research_institutions
    ADD CONSTRAINT research_institutions_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_attachment_type vocabulary_attachment_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_attachment_type
    ADD CONSTRAINT vocabulary_attachment_type_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_country vocabulary_country_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_country
    ADD CONSTRAINT vocabulary_country_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_data_sharing_plan vocabulary_data_sharing_plan_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_data_sharing_plan
    ADD CONSTRAINT vocabulary_data_sharing_plan_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_health_condition_code_type vocabulary_health_condition_code_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_health_condition_code_type
    ADD CONSTRAINT vocabulary_health_condition_code_type_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_health_condition_code_vocabulary vocabulary_health_condition_code_vocabulary_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_health_condition_code_vocabulary
    ADD CONSTRAINT vocabulary_health_condition_code_vocabulary_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_institution vocabulary_institution_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_institution
    ADD CONSTRAINT vocabulary_institution_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_institution_type vocabulary_institution_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_institution_type
    ADD CONSTRAINT vocabulary_institution_type_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_intervention vocabulary_intervention_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_intervention
    ADD CONSTRAINT vocabulary_intervention_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_monetary_material_support_type vocabulary_monetary_material_support_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_monetary_material_support_type
    ADD CONSTRAINT vocabulary_monetary_material_support_type_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_outcome_type vocabulary_outcome_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_outcome_type
    ADD CONSTRAINT vocabulary_outcome_type_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_recruitment_age_unit vocabulary_recruitment_age_unit_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_recruitment_age_unit
    ADD CONSTRAINT vocabulary_recruitment_age_unit_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_recruitment_status vocabulary_recruitment_status_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_recruitment_status
    ADD CONSTRAINT vocabulary_recruitment_status_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_secondary_identify_type vocabulary_secondary_identify_type_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_secondary_identify_type
    ADD CONSTRAINT vocabulary_secondary_identify_type_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_study_alocation vocabulary_study_alocation_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_alocation
    ADD CONSTRAINT vocabulary_study_alocation_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_study_type_expanded_access vocabulary_study_type_expanded_access_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_expanded_access
    ADD CONSTRAINT vocabulary_study_type_expanded_access_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_study_type_intervention_assignment vocabulary_study_type_intervention_assignment_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_intervention_assignment
    ADD CONSTRAINT vocabulary_study_type_intervention_assignment_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_study_type_masking vocabulary_study_type_masking_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_masking
    ADD CONSTRAINT vocabulary_study_type_masking_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_study_type_obs_study_design vocabulary_study_type_obs_study_design_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_obs_study_design
    ADD CONSTRAINT vocabulary_study_type_obs_study_design_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_study_type_phase vocabulary_study_type_phase_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_phase
    ADD CONSTRAINT vocabulary_study_type_phase_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_study_type_purpose vocabulary_study_type_purpose_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_purpose
    ADD CONSTRAINT vocabulary_study_type_purpose_pkey PRIMARY KEY (id);


--
-- Name: vocabulary_study_type_temporality vocabulary_study_type_temporality_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vocabulary_study_type_temporality
    ADD CONSTRAINT vocabulary_study_type_temporality_pkey PRIMARY KEY (id);


--
-- Name: ct_attachments ct_attachments_attachment_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_attachments
    ADD CONSTRAINT ct_attachments_attachment_type_fkey FOREIGN KEY (attachment_type) REFERENCES public.vocabulary_attachment_type(id);


--
-- Name: ct_attachments ct_attachments_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_attachments
    ADD CONSTRAINT ct_attachments_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_contact ct_contact_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_contact
    ADD CONSTRAINT ct_contact_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_country_of_recruitment ct_country_of_recruitment_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_country_of_recruitment
    ADD CONSTRAINT ct_country_of_recruitment_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_data_sharing ct_data_sharing_data_sharing_plan_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_data_sharing
    ADD CONSTRAINT ct_data_sharing_data_sharing_plan_fkey FOREIGN KEY (data_sharing_plan) REFERENCES public.vocabulary_data_sharing_plan(id);


--
-- Name: ct_data_sharing ct_data_sharing_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_data_sharing
    ADD CONSTRAINT ct_data_sharing_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_editor ct_editor_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_editor
    ADD CONSTRAINT ct_editor_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_health_condition_problem_study ct_health_condition_problem_s_health_condition_code_vocabu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_health_condition_problem_study
    ADD CONSTRAINT ct_health_condition_problem_s_health_condition_code_vocabu_fkey FOREIGN KEY (health_condition_code_vocabulary) REFERENCES public.vocabulary_health_condition_code_vocabulary(id);


--
-- Name: ct_health_condition_problem_study ct_health_condition_problem_stu_health_condition_code_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_health_condition_problem_study
    ADD CONSTRAINT ct_health_condition_problem_stu_health_condition_code_type_fkey FOREIGN KEY (health_condition_code_type) REFERENCES public.vocabulary_health_condition_code_type(id);


--
-- Name: ct_health_condition_problem_study ct_health_condition_problem_study_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_health_condition_problem_study
    ADD CONSTRAINT ct_health_condition_problem_study_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_institutions ct_institutions_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_institutions
    ADD CONSTRAINT ct_institutions_country_fkey FOREIGN KEY (country) REFERENCES public.vocabulary_country(id);


--
-- Name: ct_institutions ct_institutions_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_institutions
    ADD CONSTRAINT ct_institutions_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_institutions ct_institutions_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_institutions
    ADD CONSTRAINT ct_institutions_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.vocabulary_institution_type(id);


--
-- Name: ct_intervention_descriptor ct_intervention_descriptor_intervention_descriptor_vocabul_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention_descriptor
    ADD CONSTRAINT ct_intervention_descriptor_intervention_descriptor_vocabul_fkey FOREIGN KEY (intervention_descriptor_vocabulary) REFERENCES public.vocabulary_health_condition_code_vocabulary(id);


--
-- Name: ct_intervention_descriptor ct_intervention_descriptor_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention_descriptor
    ADD CONSTRAINT ct_intervention_descriptor_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_intervention ct_intervention_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_intervention
    ADD CONSTRAINT ct_intervention_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_outcome ct_outcome_outcome_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_outcome
    ADD CONSTRAINT ct_outcome_outcome_type_fkey FOREIGN KEY (outcome_type) REFERENCES public.vocabulary_outcome_type(id);


--
-- Name: ct_outcome ct_outcome_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_outcome
    ADD CONSTRAINT ct_outcome_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct ct_recruitment_status_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct
    ADD CONSTRAINT ct_recruitment_status_fkey FOREIGN KEY (recruitment_status) REFERENCES public.vocabulary_recruitment_status(id);


--
-- Name: ct_recruitment ct_recruitment_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_recruitment
    ADD CONSTRAINT ct_recruitment_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_results ct_results_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_results
    ADD CONSTRAINT ct_results_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_secondary_identify_numbers ct_secondary_identify_numbers_identify_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_secondary_identify_numbers
    ADD CONSTRAINT ct_secondary_identify_numbers_identify_type_fkey FOREIGN KEY (identify_type) REFERENCES public.vocabulary_secondary_identify_type(id);


--
-- Name: ct_secondary_identify_numbers ct_secondary_identify_numbers_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_secondary_identify_numbers
    ADD CONSTRAINT ct_secondary_identify_numbers_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_source_monetary_material_support ct_source_monetary_material_support_support_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_source_monetary_material_support
    ADD CONSTRAINT ct_source_monetary_material_support_support_type_fkey FOREIGN KEY (support_type) REFERENCES public.vocabulary_monetary_material_support_type(id);


--
-- Name: ct_source_monetary_material_support ct_source_monetary_material_support_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_source_monetary_material_support
    ADD CONSTRAINT ct_source_monetary_material_support_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_sponsor ct_sponsor_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_sponsor
    ADD CONSTRAINT ct_sponsor_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: ct_study_type ct_study_type_alocation_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_alocation_type_fkey FOREIGN KEY (alocation_type) REFERENCES public.vocabulary_study_alocation(id);


--
-- Name: ct_study_type ct_study_type_expanded_access_program_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_expanded_access_program_fkey FOREIGN KEY (expanded_access_program) REFERENCES public.vocabulary_study_type_expanded_access(id);


--
-- Name: ct ct_study_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct
    ADD CONSTRAINT ct_study_type_fkey FOREIGN KEY (study_type) REFERENCES public.vocabulary_intervention(id);


--
-- Name: ct_study_type ct_study_type_intervention_assignment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_intervention_assignment_fkey FOREIGN KEY (intervention_assignment) REFERENCES public.vocabulary_study_type_intervention_assignment(id);


--
-- Name: ct_study_type ct_study_type_masking_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_masking_type_fkey FOREIGN KEY (masking_type) REFERENCES public.vocabulary_study_type_masking(id);


--
-- Name: ct_study_type ct_study_type_observational_study_design_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_observational_study_design_fkey FOREIGN KEY (observational_study_design) REFERENCES public.vocabulary_study_type_obs_study_design(id);


--
-- Name: ct_study_type ct_study_type_purpose_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_purpose_fkey FOREIGN KEY (purpose) REFERENCES public.vocabulary_study_type_purpose(id);


--
-- Name: ct_study_type ct_study_type_study_phase_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_study_phase_fkey FOREIGN KEY (study_phase) REFERENCES public.vocabulary_study_type_phase(id);


--
-- Name: ct_study_type ct_study_type_temporality_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_temporality_fkey FOREIGN KEY (temporality) REFERENCES public.vocabulary_study_type_temporality(id);


--
-- Name: ct_study_type ct_study_type_trial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ct_study_type
    ADD CONSTRAINT ct_study_type_trial_id_fkey FOREIGN KEY (trial_id) REFERENCES public.ct(id);


--
-- Name: research_institutions research_institutions_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.research_institutions
    ADD CONSTRAINT research_institutions_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.vocabulary_country(id);


--
-- Name: research_institutions research_institutions_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.research_institutions
    ADD CONSTRAINT research_institutions_type_id_fkey FOREIGN KEY (type_id) REFERENCES public.vocabulary_institution_type(id);


--
-- PostgreSQL database dump complete
--

