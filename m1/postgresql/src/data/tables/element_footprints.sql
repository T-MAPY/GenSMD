SET search_path = data, public, pg_catalog;

CREATE TABLE element_footprints (
    foo_id integer NOT NULL,
    elm_proc_id integer NOT NULL,
    source_type smallint NOT NULL,
    source_elt_id character varying(20) NOT NULL,
    target_elt_id character varying(20) DEFAULT '-'::character varying NOT NULL,
    source_clearance_category integer,
    source_topology_participant boolean NOT NULL,
    footprint public.geometry(Polygon)
);

CREATE SEQUENCE element_footprints_foo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE element_footprints_foo_id_seq OWNED BY element_footprints.foo_id;

ALTER TABLE ONLY element_footprints ALTER COLUMN foo_id SET DEFAULT nextval('element_footprints_foo_id_seq'::regclass);

SET search_path TO DEFAULT;
