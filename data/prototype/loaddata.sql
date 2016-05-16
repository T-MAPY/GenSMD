TRUNCATE data.element_types CASCADE;

SELECT model.gen_load_model(
$$<?xml version="1.0" encoding="UTF-8"?>
<gen:GenModel xmlns:gen="http://gensmd.local/genmodel" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://gensmd.local/genmodel genmodel.xsd">
<SelectorList>
  <Selector>
    <ElementType geomType="line" />
    <RelationList>
      <RelationSelector>
        <Relation conflict="true" />
      </RelationSelector>
      <RelationSelector join="selector.tagdict->>'color' = relation.tagdict->>'color'">
        <Relation clearance="1.2" />
      </RelationSelector>
    </RelationList>  
  </Selector>
  <Selector cond="taglist ? 'komunikace'">
    <ElementType priority="1" topology="true" />
  </Selector>
  <Selector cond="taglist ? 'hranice'">
    <ElementType priority="4" topology="true" />
  </Selector>
  <Selector cond="taglist ? 'voda'">
    <ElementType priority="2" topology="true" />
  </Selector>
  <Selector cond="taglist ? 'zelen'">
    <ElementType priority="6" />
  </Selector>
  <Selector cond="taglist ? 'terenni stupen'">
    <ElementType priority="5" />
  </Selector>
  <Selector cond="id = '4120000'">
    <RelationList>
      <RelationSelector cond="id = '6060100'">
        <Relation>
			    <Footprint>
			      <Buffer radius="0.7" cap="flat" offset="-0.45" />
			    </Footprint>        
        </Relation>
      </RelationSelector>
    </RelationList>  
  </Selector>
  <Selector cond="geomtype = 'polygon'">
    <RelationList>
      <RelationSelector>
        <Relation conflict="false" clearance="0" />
      </RelationSelector>
    </RelationList>  
  </Selector>
</SelectorList>
<ElementTypeList>

  <ElementType id="1720000">
    <TagDict>
      <Tag key="color" value="gray" />
    </TagDict>
    <Footprint>
      <Buffer radius="0.2" />
    </Footprint>
  </ElementType>
  
  <ElementType id="2470000">
    <TagDict>
      <Tag key="color" value="gray" />
    </TagDict>
    <TagList>
      <Tag>komunikace</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="1" />
    </Footprint>
  </ElementType>
  
  <ElementType id="2480001">
    <TagDict>
      <Tag key="color" value="gray" />
    </TagDict>
    <TagList>
      <Tag>komunikace</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="1" />
    </Footprint>
  </ElementType>
  
  <ElementType id="2480006">
    <TagDict>
      <Tag key="color" value="gray" />
    </TagDict>
    <TagList>
      <Tag>komunikace</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="1" />
    </Footprint>
  </ElementType>
  
  <ElementType id="2490101">
    <TagDict>
      <Tag key="color" value="gray" />
    </TagDict>
    <TagList>
      <Tag>komunikace</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="0.75" />
    </Footprint>
  </ElementType>
  
  <ElementType id="2490200">
    <TagDict>
      <Tag key="color" value="gray" />
    </TagDict>
    <TagList>
      <Tag>komunikace</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="3" cap="flat" />
    </Footprint>
  </ElementType>
  
   
  <ElementType id="3020100">
    <TagDict>
      <Tag key="color" value="blue" />
    </TagDict>
    <TagList>
      <Tag>voda</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="0.75" />
    </Footprint>
  </ElementType>

  <ElementType id="3030000">
    <TagDict>
      <Tag key="color" value="blue" />
    </TagDict>
    <TagList>
      <Tag>voda</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="1.2" />
    </Footprint>
  </ElementType>

  <ElementType id="3040000">
    <TagDict>
      <Tag key="color" value="blue" />
    </TagDict>
    <TagList>
      <Tag>voda</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="1.2" />
    </Footprint>
  </ElementType>
     
  <ElementType id="3060000">
    <TagDict>
      <Tag key="color" value="blue" />
    </TagDict>
    <TagList>
      <Tag>voda</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="1.2" />
    </Footprint>
  </ElementType>
       
  <ElementType id="3330000" geomType="polygon">
    <TagDict>
      <Tag key="color" value="blue" />
    </TagDict>
    <TagList>
      <Tag>voda</Tag>
    </TagList>
  </ElementType>

  <ElementType id="4120000">
    <TagDict>
      <Tag key="color" value="green" />
    </TagDict>
    <TagList>
      <Tag>zelen</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="6" />
    </Footprint>
  </ElementType>
         
  <ElementType id="5210100">
    <TagDict>
      <Tag key="color" value="gray" />
    </TagDict>
    <TagList>
      <Tag>hranice</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="0.75" />
    </Footprint>
  </ElementType>
           
  <ElementType id="6060100">
    <TagDict>
      <Tag key="color" value="gray" />
    </TagDict>
    <TagList>
      <Tag>terenni stupen</Tag>
    </TagList>
    <Footprint>
      <Buffer radius="3.75" cap="flat" offset="-3.5" />
    </Footprint>
  </ElementType>
             
</ElementTypeList>

</gen:GenModel>
$$
);

SELECT model.gen_copy_model_to_data();

TRUNCATE data.elements_in CASCADE;
ALTER SEQUENCE data.elements_in_elm_id_seq RESTART WITH 1;


