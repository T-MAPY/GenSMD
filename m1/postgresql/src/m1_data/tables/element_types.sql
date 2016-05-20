SET search_path = m1_data, public, pg_catalog;

CREATE TABLE element_types (
    elt_id character varying(20) NOT NULL,
    geom_type smallint NOT NULL,
    weight integer NOT NULL,
    footprint jsonb NOT NULL,
    constraints jsonb,
    topology boolean NOT NULL
);
COMMENT ON TABLE element_types IS 'element types (category/symbol)';
COMMENT ON COLUMN element_types.elt_id IS 'element type id';
COMMENT ON COLUMN element_types.geom_type IS 'geometry type - point=1, line=2, polygon=3';
COMMENT ON COLUMN element_types.weight IS 'element type weight';
COMMENT ON COLUMN element_types.footprint IS 'footprint params in JSON';
COMMENT ON COLUMN element_types.constraints IS 'constraints params - rigidity, maximal displacement, etc.';
COMMENT ON COLUMN element_types.topology IS 'element type will be added to topology';

SET search_path TO DEFAULT;
