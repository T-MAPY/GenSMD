SET search_path = m1_data, public, pg_catalog;

CREATE TABLE elements_in (
    elm_id integer NOT NULL,
    elt_id character varying(20) NOT NULL,
    rotation numeric(7,4) DEFAULT 0 NOT NULL,
    geom public.geometry NOT NULL,
    topo_pt topology.topogeometry,
    topo_ln topology.topogeometry,
    topo_pl topology.topogeometry,
    CONSTRAINT check_topogeom_topo_ln CHECK ((((topo_ln).topology_id = 9) AND ((topo_ln).layer_id = 2) AND ((topo_ln).type = 2))),
    CONSTRAINT check_topogeom_topo_pl CHECK ((((topo_pl).topology_id = 9) AND ((topo_pl).layer_id = 3) AND ((topo_pl).type = 3))),
    CONSTRAINT check_topogeom_topo_pt CHECK ((((topo_pt).topology_id = 9) AND ((topo_pt).layer_id = 1) AND ((topo_pt).type = 1)))
);
COMMENT ON TABLE elements_in IS 'source input elements for a generalization';
COMMENT ON COLUMN elements_in.elm_id IS 'element id';
COMMENT ON COLUMN elements_in.elt_id IS 'element type';
COMMENT ON COLUMN elements_in.geom IS 'geometry';

CREATE SEQUENCE elements_in_elm_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE elements_in_elm_id_seq OWNED BY elements_in.elm_id;

ALTER TABLE ONLY elements_in ALTER COLUMN elm_id SET DEFAULT nextval('elements_in_elm_id_seq'::regclass);

SET search_path TO DEFAULT;
