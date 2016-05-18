SET search_path = m1_model, public, pg_catalog;

CREATE TABLE element_types_relations_load (
    id_from character varying(20) NOT NULL,
    id_to character varying(20) NOT NULL,
    merged jsonb
);

SET search_path TO DEFAULT;
