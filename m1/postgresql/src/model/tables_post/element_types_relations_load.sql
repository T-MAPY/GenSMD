SET search_path = model, public, pg_catalog;

ALTER TABLE ONLY element_types_relations_load
    ADD CONSTRAINT element_types_relations_load_pkey PRIMARY KEY (id_from, id_to);

CREATE TRIGGER trigger_element_types_relations_load BEFORE UPDATE ON element_types_relations_load FOR EACH ROW EXECUTE PROCEDURE gen_trigger_element_types_relations_load();

SET search_path TO DEFAULT;
