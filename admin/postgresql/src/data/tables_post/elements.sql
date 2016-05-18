SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY elements
    ADD CONSTRAINT elements_in_pkey PRIMARY KEY (elm_id);

CREATE INDEX elements_source_elt_id_idx ON elements USING btree (source_elt_id);

CREATE INDEX elements_state_idx ON elements USING btree (state);

CREATE INDEX elements_target_elt_id_idx ON elements USING btree (target_elt_id);

SET search_path TO DEFAULT;
