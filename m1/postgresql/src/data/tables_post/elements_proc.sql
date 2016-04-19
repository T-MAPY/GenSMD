SET search_path = data, public, pg_catalog;

ALTER TABLE ONLY elements_proc
    ADD CONSTRAINT elements_proc_pkey PRIMARY KEY (elm_proc_id);

CREATE TRIGGER trigger_elements_proc AFTER INSERT OR UPDATE ON elements_proc FOR EACH ROW EXECUTE PROCEDURE m1.gen_trigger_elements_proc();

SET search_path TO DEFAULT;
