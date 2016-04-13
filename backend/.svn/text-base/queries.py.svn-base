
import config

def innerqry(sig):
  return '''
     SELECT ids.userkey, m.name, array_to_string(array_accum(m.value),',')
       FROM descriptor_stage m, resource_stage as ids 
      WHERE ids.id = m.res_id 
        AND ids.signature = '%s'
   GROUP BY ids.userkey, m.name 
   ORDER BY 1,2
''' % (sig,)

def crossqry(inqry, cnt, scheme):
   return '''
     SELECT tbl.* FROM crosstab('\n %s \n', %i ) as tbl(%s)
''' %  (inqry, cnt, scheme)

compute_resource_signatures = '''
    -- Each resource has a *signature*: the set of properties 
    -- used to describe it.
    -- group by res_id, accumulating the names into an array
    -- these tuples have type (res_id, <set>)
    -- where <set> is represented as a sorted string 'name1, name2, ...'

    SELECT res_id, array_to_string(array_accum(name),',') as signature 
    FROM (

      -- now sort the records by userkey then name
      SELECT res_id, name 
      FROM descriptor_stage
      ORDER BY res_id, name

    ) as rawlist 
    GROUP BY res_id
'''

update_resources_with_signatures = '''
   UPDATE resource_stage
      SET signature = m.signature
     FROM (\n %s \n) as m
    WHERE m.res_id = id
''' % (compute_resource_signatures,)

new_signatures = '''
     SELECT rs.signature, nextval('table_id_seq')
       FROM resource_stage rs LEFT OUTER JOIN signature s
         ON rs.signature = s.signature
      WHERE s.signature IS NULL
   GROUP BY rs.signature
'''


new_resources = '''
    SELECT rs.userkey, rs.signature
      FROM resource_stage rs LEFT OUTER JOIN resource r 
        ON (rs.userkey = r.userkey) 
     WHERE r.userkey IS NULL
'''

insert_new_resources = '''
   INSERT INTO resource (userkey, signature) (%s)
''' % (new_resources,)

def load_triples(fname=config.triplefile):
  return '''
    \copy triple_stage (subject, property, object) from '%s' with delimiter ';'
''' % (fname,)

def load_resources(dir=config.tmpdir):
  return '''
    \copy resource_stage (id, userkey) from '%s/%s' with delimiter ';'
''' % (dir, config.resourceFileName)

def load_descriptors(dir=config.tmpdir):
  return  '''
    \copy descriptor_stage(res_id, name, value, description, type) from '%s/%s' with delimiter ';'
''' % (dir, config.descriptorFileName)

signature_star = '''SELECT tabletag, signature FROM signature'''

delete_staging_area = '''
  ALTER TABLE descriptor_stage DROP CONSTRAINT descriptor_stage_res_id_fkey;
  TRUNCATE resource_stage;
  TRUNCATE descriptor_stage;
  ALTER TABLE descriptor_stage ADD CONSTRAINT "descriptor_stage_res_id_fkey" 
       FOREIGN KEY (res_id) REFERENCES resource_stage(id);
'''

def read_cache(qrystr):
  qry  = '''
  SELECT value 
    FROM cachedquery, cachedqueryresult  
   WHERE qid = id AND query_string = '%s' 
   ''' % (qrystr,)
  return qry

def update_cache(callstr): 
  qry  = '''
  UPDATE cachedquery 
     SET hit_count = hit_count+1
   WHERE query_string = '%s' 
  ''' % (callstr,)
  return qry

def iscached(callstr):
  qry  = '''
  SELECT * FROM cachedquery
   WHERE query_string = '%s' 
  ''' % (callstr,)
  return qry

create_query_cache = '''
  CREATE TABLE cachedquery (
    id int, 
    query_string text, 
    hit_count int, 
    result_size int, 
    PRIMARY KEY (id)
  );

  CREATE TABLE cachedqueryresult (
    qid int REFERENCES cachedquery(id) ON DELETE CASCADE,
    value text
  );
'''

drop_query_cache = '''
  DROP TABLE cachedqueryresult;
  DROP TABLE cachedquery;
'''

def cache_insert(callstr, resultsize):
  return ''' 
  INSERT INTO CachedQuery 
  VALUES (nextval('id_seq'), '%s',  1, %s);
  ''' % (callstr, resultsize)
  
last_id = '''
  SELECT currval('id_seq');
  '''
def cache_result_insert(id, val):
 return '''
  INSERT INTO CachedQueryResult 
  VALUES (%s,  '%s');''' % (id, val)

resources_from_triples = '''
  INSERT INTO resource_stage (id, userkey) (
     SELECT nextval('id_seq'), subject
       FROM triple_stage ts 
            LEFT OUTER JOIN 
            resource_stage rs 
            ON (ts.subject = rs.userkey)
      WHERE rs.userkey IS NULL
   GROUP BY subject
  );
'''

def descriptors_from_triples(delim):
  return  '''
  INSERT INTO descriptor_stage (res_id, name, value) (
    SELECT id, property, array_to_string(array_accum(object),'%s') as value
      FROM resource_stage, triple_stage
     WHERE userkey = subject
  GROUP BY id, property
  );
''' % (delim,)

def copy_triples(filename, delim=config.ascii_ingest_field_delimiter, csv="csv header"):
  return '''\copy triple_stage from '%s' with delimiter %s %s''' % (filename, delim, csv)

clear_triples = '''TRUNCATE TABLE triple_stage'''
