SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY element_types_relations
    ADD CONSTRAINT element_types_relations_pkey PRIMARY KEY (elt_id_1, elt_id_2);

SET search_path TO DEFAULT;
