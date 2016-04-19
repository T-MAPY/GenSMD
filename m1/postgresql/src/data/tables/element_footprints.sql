SET search_path = data, public, pg_catalog;

CREATE TABLE element_footprints (
    elm_proc_id integer NOT NULL,
    source_type smallint NOT NULL,
    source_elt_id character varying(20) NOT NULL,
    target_elt_id character varying(20) DEFAULT '-'::character varying NOT NULL,
    footprint public.geometry(Polygon)
);

SET search_path TO DEFAULT;
