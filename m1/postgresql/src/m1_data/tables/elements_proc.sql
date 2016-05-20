SET search_path = m1_data, public, pg_catalog;

CREATE TABLE elements_proc (
    elm_proc_id integer NOT NULL,
    elm_id integer,
    edge_id integer,
    weight integer,
    geom public.geometry NOT NULL
);

CREATE SEQUENCE elements_proc_elm_proc_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE elements_proc_elm_proc_id_seq OWNED BY elements_proc.elm_proc_id;

ALTER TABLE ONLY elements_proc ALTER COLUMN elm_proc_id SET DEFAULT nextval('elements_proc_elm_proc_id_seq'::regclass);

SET search_path TO DEFAULT;
