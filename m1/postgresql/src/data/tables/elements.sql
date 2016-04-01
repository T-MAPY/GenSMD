SET search_path = data, public, pg_catalog;

CREATE TABLE elements (
    elm_id integer NOT NULL,
    elt_id integer NOT NULL,
    geom public.geometry NOT NULL,
    rotation numeric(7,4) DEFAULT 0 NOT NULL,
    source_id numeric(38,0),
    source_elt_id integer
);
COMMENT ON TABLE elements IS 'výèet všech elementù, které se zpracovávají';
COMMENT ON COLUMN elements.elm_id IS 'identifikátor';
COMMENT ON COLUMN elements.elt_id IS 'typ elementu';
COMMENT ON COLUMN elements.geom IS 'geometrie';
COMMENT ON COLUMN elements.source_id IS 'pùvodní id';
COMMENT ON COLUMN elements.source_elt_id IS 'pùvodní element type';

CREATE SEQUENCE elements_elm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE elements_elm_id_seq OWNED BY elements.elm_id;

ALTER TABLE ONLY elements ALTER COLUMN elm_id SET DEFAULT nextval('elements_elm_id_seq'::regclass);

SET search_path TO DEFAULT;
