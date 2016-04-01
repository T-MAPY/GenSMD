SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY element_types
    ADD CONSTRAINT element_types_pkey PRIMARY KEY (elt_id);

SET search_path TO DEFAULT;
