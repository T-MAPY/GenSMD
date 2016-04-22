SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY element_footprints
    ADD CONSTRAINT element_footprints_pkey PRIMARY KEY (elm_proc_id, foo_type, elt_id_from, elt_id_to);

CREATE UNIQUE INDEX element_footprints_foo_id_idx ON element_footprints USING btree (foo_id);

CREATE INDEX element_footprints_geom_idx ON element_footprints USING gist (geom);

SET search_path TO DEFAULT;
