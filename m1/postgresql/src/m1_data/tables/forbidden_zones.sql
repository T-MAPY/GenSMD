SET search_path = m1_data, public, pg_catalog;

CREATE TABLE forbidden_zones (
    frz_id integer NOT NULL,
    geom public.geometry NOT NULL
);
COMMENT ON TABLE forbidden_zones IS 'geometries defining forbidden zones';
COMMENT ON COLUMN forbidden_zones.frz_id IS 'zone id';
COMMENT ON COLUMN forbidden_zones.geom IS 'zone geometry';

CREATE SEQUENCE forbidden_zones_frz_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE forbidden_zones_frz_id_seq OWNED BY forbidden_zones.frz_id;

ALTER TABLE ONLY forbidden_zones ALTER COLUMN frz_id SET DEFAULT nextval('forbidden_zones_frz_id_seq'::regclass);

SET search_path TO DEFAULT;
