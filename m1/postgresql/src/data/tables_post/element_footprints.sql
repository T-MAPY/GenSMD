SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY element_footprints
    ADD CONSTRAINT element_footprints_pkey PRIMARY KEY (elm_proc_id, source_type, source_elt_id, target_elt_id);

SET search_path TO DEFAULT;
