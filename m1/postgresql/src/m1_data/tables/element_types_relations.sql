SET search_path = m1_data, public, pg_catalog;

CREATE TABLE element_types_relations (
    elt_id_from character varying(20) NOT NULL,
    elt_id_to character varying(20) NOT NULL,
    conflict boolean DEFAULT false NOT NULL,
    clearance double precision DEFAULT 0 NOT NULL,
    footprint_from jsonb,
    footprint_to jsonb
);

SET search_path TO DEFAULT;
