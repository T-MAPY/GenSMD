CREATE OR REPLACE FUNCTION utils.xmldoctojsondoc(xml text)
 RETURNS text
 LANGUAGE plpython3u
AS $function$
  import xmltodict, json, re 
  from collections import OrderedDict

  def lower_keys(x, parentislist=False, parentisdict=False):
    ret = x
    if isinstance(x, list):
      ret = [lower_keys(v) for v in x]
    elif isinstance(x, dict):
      ret = OrderedDict((k.lower().lstrip('@#'), 
        lower_keys(
          v, 
          re.search('list$', k, re.IGNORECASE) is not None,
          re.search('dict$', k, re.IGNORECASE) is not None
        )
      ) for k, v in x.items())
    if parentisdict:
      if x is None:
        return {}
      else:
        el = next(iter(ret.values()))
        if isinstance(el, dict):
          return dict([(el['key'], el['value'])])
        elif isinstance(el, list):
          d = OrderedDict((v['key'], v['value']) for v in el)
          return d
    elif parentislist:
      if x is None:
        return []
      else:
        el = next(iter(ret.values()))
        return el if isinstance(el, list) else [el]
    else:
      return ret
          
  d = xmltodict.parse(xml)
  d = lower_keys(d)
  res = json.dumps(d)
  # plpy.notice(res) 
  
  return res
$function$
;