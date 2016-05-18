CREATE OR REPLACE FUNCTION m1_utils.jsondoc_extend(js1 text, js2 text)
 RETURNS text
 LANGUAGE plpython3u
AS $function$
  import json
  from copy import deepcopy
  
  def dict_merge(target, *args):
    # Merge multiple dicts
    if len(args) > 1:
      for obj in args:
        dict_merge(target, obj)
      return target
   
    # Recursively merge dicts and set non-dict values
    obj = args[0]
    if not isinstance(obj, dict):
      return obj
    for k, v in obj.items():
      if k in target and isinstance(target[k], dict):
        dict_merge(target[k], v)
      else:
        target[k] = deepcopy(v)
    return target

  d1 = json.loads(js1)
  d2 = json.loads(js2)
  
  merged = dict_merge(d1, d2)
  
  return json.dumps(merged)
$function$
;