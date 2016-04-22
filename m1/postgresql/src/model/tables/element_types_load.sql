SET search_path = model, public, pg_catalog;

CREATE TABLE element_types_load (
    id character varying(20) NOT NULL,
    source jsonb,
    merged jsonb
);

SET search_path TO DEFAULT;
