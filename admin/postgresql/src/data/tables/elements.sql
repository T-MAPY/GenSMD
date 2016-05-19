SET search_path = data, public, pg_catalog;

CREATE TABLE elements (
    elm_id integer NOT NULL,
    source_id character varying(100),
    source_elt_id character varying(50),
    source_rotation numeric(7,4) DEFAULT 0 NOT NULL,
    source_geom public.geometry NOT NULL,
    target_elt_id character varying(50) NOT NULL,
    target_rotation numeric(7,4) DEFAULT 0 NOT NULL,
    target_geom public.geometry NOT NULL,
    state integer DEFAULT 0 NOT NULL,
    log text,
    CONSTRAINT check_elements_state CHECK (((state >= 0) AND (state <= 4)))
);
COMMENT ON COLUMN elements.state IS 'element state 
0 - target_geom=source_geom
1 - geometry changed - new value in target_geom
2 - deleted - target_geom = null
3 - element type changed - new value in target_elm_type
4 - new element - source_id contains source_id list of parent elements';

CREATE SEQUENCE elements_elm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE elements_elm_id_seq OWNED BY elements.elm_id;

ALTER TABLE ONLY elements ALTER COLUMN elm_id SET DEFAULT nextval('elements_elm_id_seq'::regclass);

SET search_path TO DEFAULT;
