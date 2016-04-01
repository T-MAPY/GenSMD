SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY elements
    ADD CONSTRAINT elements_pkey PRIMARY KEY (elm_id);

SET search_path TO DEFAULT;
