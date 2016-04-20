TRUNCATE data.element_types CASCADE;

INSERT INTO data.element_types (elt_id, geom_type, priority, footprint_params, clearance_category, topology_participant) VALUES 
  ('1720000',2,1,'{"buffer":{"radius":0.2}}',1,true),
-- cesta                                                                                                                                                                       
  ('2470000',2,1,'{"buffer":{"radius":1}}',1,true),
  ('2480001',2,1,'{"buffer":{"radius":1}}',1,true),
  ('2480006',2,1,'{"buffer":{"radius":1}}',1,true),
  ('2490101',2,1,'{"buffer":{"radius":0.75}, "overrides": {"5210100": {"buffer": {"radius": 0.7, "offset": 0}}}}',1,true),
  ('2490200',2,1,'{"buffer":{"radius":3, "cap": "flat"}}',1,true),
-- vodni tok                                                                                                                                                                   
  ('3020100',2,1,'{"buffer":{"radius":0.75}}',1,false),
-- vodni kanal
  ('3030000',2,1,'{"buffer":{"radius":1.2}}',1,true),
  ('3040000',2,1,'{"buffer":{"radius":1.2}}',1,false),
-- brehovka                                                                                                                                                                    
  ('3060000',2,1,'{"buffer":{"radius":0.75}}',1,true),
-- vodni plocha                                                                                                                                                                
  ('3330000',3,1,'{"buffer":{"radius":0.75}}',1,true),
-- zelen                                                                                                                                                                       
  ('4120000',2,1,'{"buffer":{"radius":6}, "overrides": {"3060000": {"buffer": {"radius": 0.7, "offset": -0.45}}}}',1,false),
-- hr. uzivani                                                                                                                                                                 
  ('5210100',2,1,'{"buffer":{"radius":0.75}}',1,true),
-- terenni stupen                                                                                                                                                              
  ('6060100',2,1,'{"buffer":{"radius":3.75, "cap": "flat", "offset": -3.5}, "overrides": {"4120000": {"buffer": {"radius": 0.7, "offset": -0.45}}}}', 1, false)
;

TRUNCATE data.elements_in CASCADE;
ALTER SEQUENCE data.elements_in_elm_id_seq RESTART WITH 1;
