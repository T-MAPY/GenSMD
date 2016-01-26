SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY features
    ADD CONSTRAINT features_pkey PRIMARY KEY (id);

CREATE INDEX features_feature_id_idx ON features USING btree (feature_id);

CREATE INDEX features_geom_idx ON features USING gist (geom);

CREATE INDEX features_geom_symbol_idx ON features USING gist (geom_symbol);

CREATE INDEX features_ogc_src_tbl_idx ON features USING btree (src_tbl);

CREATE INDEX features_src_id_idx ON features USING btree (src_id);

CREATE INDEX features_strategy_id_idx ON features USING btree (strategy_id);

SET search_path TO DEFAULT;
