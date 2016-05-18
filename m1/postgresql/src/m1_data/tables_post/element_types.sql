SET search_path = m1_data, public, pg_catalog;

ALTER TABLE ONLY element_types
    ADD CONSTRAINT element_types_pkey PRIMARY KEY (elt_id);

CREATE INDEX element_types_footprint_overrides_idx ON element_types USING btree (((footprint ? 'overrides'::text))) WHERE (footprint ? 'overrides'::text);

SET search_path TO DEFAULT;
