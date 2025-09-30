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
