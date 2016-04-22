SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY element_types_relations
    ADD CONSTRAINT element_types_relations_pkey PRIMARY KEY (elt_id_from, elt_id_to);

CREATE INDEX element_types_relations_conflict_idx ON element_types_relations USING btree (conflict) WHERE conflict;

CREATE INDEX element_types_relations_elt_id_from_idx ON element_types_relations USING btree (elt_id_from);

CREATE INDEX element_types_relations_elt_id_to_idx ON element_types_relations USING btree (elt_id_to);

CREATE INDEX element_types_relations_footprint_from_idx ON element_types_relations USING btree (footprint_from) WHERE (footprint_from IS NOT NULL);

CREATE INDEX element_types_relations_footprint_to_idx ON element_types_relations USING btree (footprint_to) WHERE (footprint_to IS NOT NULL);

SET search_path TO DEFAULT;
