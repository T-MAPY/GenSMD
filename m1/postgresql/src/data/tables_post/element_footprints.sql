SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY element_footprints
    ADD CONSTRAINT element_footprints_pkey PRIMARY KEY (elm_proc_id, source_type, source_elt_id, target_elt_id);

CREATE UNIQUE INDEX element_footprints_foo_id_idx ON element_footprints USING btree (foo_id);

CREATE INDEX element_footprints_geom_idx ON element_footprints USING gist (footprint);

SET search_path TO DEFAULT;
