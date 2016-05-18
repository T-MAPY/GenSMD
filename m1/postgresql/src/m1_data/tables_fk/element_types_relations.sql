SET search_path = m1_data, public, pg_catalog;

ALTER TABLE ONLY element_types_relations
    ADD CONSTRAINT fk_element_types_relations_element_types_1 FOREIGN KEY (elt_id_from) REFERENCES element_types(elt_id);

ALTER TABLE ONLY element_types_relations
    ADD CONSTRAINT fk_element_types_relations_element_types_2 FOREIGN KEY (elt_id_to) REFERENCES element_types(elt_id);

SET search_path TO DEFAULT;
