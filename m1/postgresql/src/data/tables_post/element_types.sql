SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY element_types
    ADD CONSTRAINT element_types_pkey PRIMARY KEY (elt_id);

CREATE INDEX element_types_footprint_overrides_idx ON element_types USING btree (((footprint_params ? 'overrides'::text))) WHERE (footprint_params ? 'overrides'::text);

SET search_path TO DEFAULT;
