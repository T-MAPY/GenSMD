CREATE OR REPLACE FUNCTION tests.test_xmldoctojsondoc()
 RETURNS TABLE(name character varying, result boolean)
 LANGUAGE plpgsql
AS $function$
BEGIN
  
  RETURN QUERY (
    SELECT 'm1.xmldoctojsondoc - simple'::varchar AS name, 
    COALESCE(
      (SELECT utils.xmldoctojsondoc(
          '<root><elm>a</elm></root>')) 
        = '{"root": {"elm": "a"}}'
      , false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.xmldoctojsondoc - attributes'::varchar AS name, 
    COALESCE(
      (SELECT utils.xmldoctojsondoc(
          '<root><elm a="1" b="x"/></root>')) 
        = '{"root": {"elm": {"a": "1", "b": "x"}}}'
      , false) AS result
  );
  
  RETURN QUERY (
    SELECT 'm1.xmldoctojsondoc - list one'::varchar AS name, 
    COALESCE(
      (SELECT utils.xmldoctojsondoc(
          '<root><elmlist><elm id="1"/></elmlist></root>')) 
        = '{"root": {"elmlist": [{"id": "1"}]}}'
      , false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.xmldoctojsondoc - list more'::varchar AS name, 
    COALESCE(
      (SELECT utils.xmldoctojsondoc(
          '<root><elmlist><elm id="1"/><elm id="2"/></elmlist></root>')) 
        = '{"root": {"elmlist": [{"id": "1"}, {"id": "2"}]}}'
      , false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.xmldoctojsondoc - list empty'::varchar AS name, 
    COALESCE(
      (SELECT utils.xmldoctojsondoc(
          '<root><elmlist></elmlist></root>')) 
        = '{"root": {"elmlist": {}}}'
      , false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.xmldoctojsondoc - dict one'::varchar AS name, 
    COALESCE(
      (SELECT utils.xmldoctojsondoc(
          '<root><elmdict><item key="a" value="1"/></elmdict></root>')) 
        = '{"root": {"elmdict": {"a": "1"}}}'
      , false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.xmldoctojsondoc - dict more'::varchar AS name, 
    COALESCE(
      (SELECT utils.xmldoctojsondoc(
          '<root><elmdict><item key="a" value="1" /><item key="b" value="2" /></elmdict></root>')) 
        = '{"root": {"elmdict": {"a": "1", "b": "2"}}}'
      , false) AS result
  );

  RETURN QUERY (
    SELECT 'm1.xmldoctojsondoc - dict empty'::varchar AS name, 
    COALESCE(
      (SELECT utils.xmldoctojsondoc(
          '<root><elmdict></elmdict></root>')) 
        = '{"root": {"elmdict": {}}}'
      , false) AS result
  );
  
END;
$function$
;