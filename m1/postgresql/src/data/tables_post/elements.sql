SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY elements
    ADD CONSTRAINT elements_pkey PRIMARY KEY (elm_id);

CREATE INDEX elements_footprint_idx ON elements USING gist (footprint);

CREATE INDEX elements_geom_idx ON elements USING gist (geom);

SET search_path TO DEFAULT;
