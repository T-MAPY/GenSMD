SET search_path = data, public, pg_catalog;

CREATE TABLE features (
    id integer NOT NULL,
    feature_id integer NOT NULL,
    src_tbl character varying(50),
    src_id integer,
    symbol integer,
    step integer DEFAULT 1,
    state integer DEFAULT 1,
    strategy_id integer,
    geom public.geometry(Geometry),
    geom_symbol public.geometry(Geometry)
);

CREATE SEQUENCE features_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE features_id_seq OWNED BY features.id;

ALTER TABLE ONLY features ALTER COLUMN id SET DEFAULT nextval('features_id_seq'::regclass);

SET search_path TO DEFAULT;
