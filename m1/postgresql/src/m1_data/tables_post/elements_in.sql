SET search_path = m1_data, public, pg_catalog;

ALTER TABLE ONLY elements_in
    ADD CONSTRAINT elements_in_pkey PRIMARY KEY (elm_id);

CREATE INDEX elements_in_geom_idx ON elements_in USING gist (geom);

SET search_path TO DEFAULT;
