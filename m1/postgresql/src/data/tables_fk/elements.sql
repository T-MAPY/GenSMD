SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY elements
    ADD CONSTRAINT fk_elements_element_types FOREIGN KEY (elt_id) REFERENCES element_types(elt_id);

SET search_path TO DEFAULT;
