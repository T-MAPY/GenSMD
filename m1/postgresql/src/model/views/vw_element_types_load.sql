CREATE OR REPLACE VIEW model.vw_element_types_load AS
 SELECT element_types_load.id,
    element_types_load.merged ->> 'geomtype'::text AS geomtype,
    (element_types_load.merged ->> 'priority'::text)::integer AS priority,
        CASE element_types_load.merged ->> 'topology'::text
            WHEN 'true'::text THEN true
            ELSE false
        END AS topology,
    element_types_load.merged -> 'tagdict'::text AS tagdict,
    element_types_load.merged -> 'taglist'::text AS taglist,
    element_types_load.merged -> 'footprint'::text AS footprint
   FROM model.element_types_load;;