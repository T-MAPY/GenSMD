SET search_path = data, public, pg_catalog;

CREATE TABLE element_types (
    elt_id integer NOT NULL,
    geom_type smallint NOT NULL,
    priority integer,
    footprint_params public.hstore NOT NULL,
    constraints_params public.hstore,
    clearance_category integer,
    topology_participant boolean NOT NULL
);
COMMENT ON TABLE element_types IS 'typy (kategorie/symboly) elementù';
COMMENT ON COLUMN element_types.elt_id IS 'identifikátor';
COMMENT ON COLUMN element_types.geom_type IS 'typ geometrie - bod, linie, polygon';
COMMENT ON COLUMN element_types.priority IS 'priorita typu elementu';
COMMENT ON COLUMN element_types.footprint_params IS 'parametry pro vytvoøení footprintu v JSON';
COMMENT ON COLUMN element_types.constraints_params IS 'parametry omezení - rigidita, maximální míra posunu, nehnutelnost, atd.';
COMMENT ON COLUMN element_types.clearance_category IS 'kategorie vizuálního odstupu (napø. barevná charakteristika)';
COMMENT ON COLUMN element_types.topology_participant IS 'elementy tohoto typu se úèastní / neúèastní topologie';

SET search_path TO DEFAULT;
