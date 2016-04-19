SET search_path = data, public, pg_catalog;

CREATE TABLE element_types (
    elt_id character varying(20) NOT NULL,
    geom_type smallint NOT NULL,
    priority integer,
    footprint_params jsonb NOT NULL,
    constraints_params jsonb,
    clearance_category integer,
    topology_participant boolean NOT NULL
);
COMMENT ON TABLE element_types IS 'element types (category/symbol)';
COMMENT ON COLUMN element_types.elt_id IS 'element type id';
COMMENT ON COLUMN element_types.geom_type IS 'geometry type - point=1, line=2, polygon=3';
COMMENT ON COLUMN element_types.priority IS 'element type priority';
COMMENT ON COLUMN element_types.footprint_params IS 'footprintu params in JSON';
COMMENT ON COLUMN element_types.constraints_params IS 'constraints params - rigidity, maximal displacement, etc.';
COMMENT ON COLUMN element_types.clearance_category IS 'visual clearence category (e.g. color)';
COMMENT ON COLUMN element_types.topology_participant IS 'element type will be added to topology';

SET search_path TO DEFAULT;
