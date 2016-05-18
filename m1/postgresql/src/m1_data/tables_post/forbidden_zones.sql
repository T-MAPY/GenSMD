SET search_path = m1_data, public, pg_catalog;

ALTER TABLE ONLY forbidden_zones
    ADD CONSTRAINT forbidden_zones_pkey PRIMARY KEY (frz_id);

SET search_path TO DEFAULT;
