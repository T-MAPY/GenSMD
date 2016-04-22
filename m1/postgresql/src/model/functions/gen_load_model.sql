CREATE OR REPLACE FUNCTION model.gen_load_model(xmldoc text)
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE
  m jsonb;
  rsel record;
  rrel record;
  sqlinsert text;
BEGIN
  m := utils.xmldoctojsondoc(xmldoc)::jsonb;
  -- remove root
  m := jsonb_extract_path(m, (SELECT jsonb_object_keys(m) LIMIT 1));
  --RAISE NOTICE '%', m;
  
  -- truncate old data
  TRUNCATE model.element_types_load;
  TRUNCATE model.element_types_relations_load;
  
  -- load element types
  INSERT INTO model.element_types_load (id, source, merged)
    SELECT et->>'id', et, et FROM jsonb_array_elements(m->'elementtypelist') et;

  -- process selectors
  FOR rsel IN 
    SELECT 
      COALESCE(sel->>'cond', 'TRUE') as cond, 
      sel->'elementtype' as elementtype,
      sel->'relationlist' as relationlist 
    FROM jsonb_array_elements(m->'selectorlist') sel 
  LOOP
    -- update relations
    FOR rrel IN 
      SELECT 
        COALESCE(rel->>'cond', 'TRUE') as cond,
        COALESCE(rel->>'join', 'TRUE') as condjoin,
        rel->'relation' as relation
      FROM jsonb_array_elements(rsel.relationlist) rel
    LOOP
      BEGIN
        sqlinsert := 'INSERT INTO model.element_types_relations_load (id_from, id_to, merged)
                      SELECT %fields%, $1 
                      FROM 
                        (SELECT * FROM model.vw_element_types_load WHERE ' || rsel.cond || ') selector
                        INNER JOIN 
                        (SELECT * FROM model.vw_element_types_load WHERE ' || rrel.cond || ') relation
                        ON ' || rrel.condjoin || '
                    ON CONFLICT ON CONSTRAINT element_types_relations_load_pkey 
                    DO UPDATE SET 
                      merged = EXCLUDED.merged';

        --RAISE NOTICE '%', sqlinsert;
        
        -- insert for both directions and set footprint orientation
        EXECUTE replace(sqlinsert, '%fields%', 'selector.id, relation.id') 
          USING CASE WHEN rrel.relation ? 'footprint' THEN jsonb_set(rrel.relation - 'footprint', array['footprint_to'], rrel.relation->'footprint') ELSE rrel.relation END;
          
        EXECUTE replace(sqlinsert, '%fields%', 'relation.id, selector.id') 
          USING CASE WHEN rrel.relation ? 'footprint' THEN jsonb_set(rrel.relation - 'footprint', array['footprint_from'], rrel.relation->'footprint') ELSE rrel.relation END;
        
      EXCEPTION
        WHEN OTHERS THEN
          RAISE EXCEPTION 
            'GEN: Selector or Relation Error: selector cond="%"; relation cond="%", join="%"', 
            rsel.cond, rrel.cond, rrel.condjoin 
            USING HINT = 'Please check the selector condition.';
      END;    
    END LOOP;

    -- update element types
    IF (rsel.elementtype IS NOT NULL) THEN
      BEGIN
        EXECUTE 'UPDATE model.element_types_load SET merged = $1
                 WHERE id IN (SELECT id FROM model.vw_element_types_load WHERE ' || rsel.cond || ')'
          USING rsel.elementtype;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE EXCEPTION 
            'GEN: Selector Error: %', 
            rsel.cond 
            USING HINT = 'Please check the selector condition.';
      END;    
   END IF;
  END LOOP;

  RETURN true;
END;
$function$
;