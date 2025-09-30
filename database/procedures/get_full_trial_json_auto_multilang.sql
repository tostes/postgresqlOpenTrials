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
