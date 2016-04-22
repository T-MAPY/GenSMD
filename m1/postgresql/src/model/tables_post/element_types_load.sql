SET search_path = model, public, pg_catalog;

ALTER TABLE ONLY element_types_load
    ADD CONSTRAINT element_types_load_pkey PRIMARY KEY (id);

CREATE TRIGGER trigger_element_types_load BEFORE UPDATE ON element_types_load FOR EACH ROW EXECUTE PROCEDURE gen_trigger_element_types_load();

SET search_path TO DEFAULT;
