#!/usr/local/bin/python

import os, sys, time
import traceback as tb
import re
import config

sys.path.append(config.app_path + "/backend/")

import qdb
import qlog
import operator as op
import re

import inspect
import sigmanager, signature
import queries

db = qdb.quarrydb()

sm = sigmanager.SignatureManager(db)

patt = '''(\'|\\\|;|\n|:)'''
pattre = re.compile(patt)

# response time threshold in seconds above which we cache the query results
INTERACTIVE_SPEED = 3

def asList(s):
  seq = list(s)
  seq.sort()
  return seq

def getCachedResults(callstr):
  return db.execQuery(queries.read_cache(callstr))
  
def updateCache(callstr):
  if config.use_query_cache:
    return db.execCommand(queries.update_cache(callstr))

def iscached(callstr):
  if config.use_query_cache:
    return len(db.execQuery(queries.iscached(callstr)))
  else:
    return 0

def cacheQuery(callstr, results):

  if not config.use_query_cache: return True
  db.execCommand("BEGIN TRANSACTION")
  try:
    db.execCommand(queries.cache_insert(callstr, len(results)))

    (id,) = db.execQuery(queries.last_id)[0]
    qry = '\n'.join([queries.cache_result_insert(id, r) for r in results])
    if qry: db.execCommand(qry);
  except: 
    (e, v, t) = sys.exc_info()
    qlog.critical(str(e) + ": " + str(v))
    db.execCommand('rollback;')
    # re-raise the error; it's probably fatal
    raise e, v, t
    return False 
  else:
    db.execCommand('commit;')
    return True

def ValueQuery(conditions, attributes=[]):
  '''Build a SQL query over the signature extents returning the values 
of 'attributes' for resources satisfying 'conditions'. 
(i.e., SELECT attributes FROM resources WHERE conditions)'''

  # find signatures possessing every property used in conditions, 
  # and every property to be returned. 
  # (think of all tables with columns mentioned in SELECT and WHERE clauses)
  attrs = set(dict(conditions).keys() + attributes)
  tocheck = sm.MatchingSignatures(attrs)
  # by default, assume we will project onto the condition attributes           
  if not attributes: 
    attributes = zip(*conditions)[0]
  else:
    attributes = list(set(attributes))

  def makeqry(p):
    return p.ConjunctiveQuery(conditions, attributes, True)

  queries = [makeqry(p) for p in tocheck]
  qry = db.Union(queries)
  return qry

def PagedQuery(qry, offset, limit=None, sorted=False):
  if qry: 
    if sorted: qry += ' ORDER BY "%s"' % ('","'.join(attributes),)
    # LIMIT all should be equivalent to omitting the LIMIT clause, but 8.1 crashes
    # http://www.postgresql.org/docs/8.2/static/release-8-2-1.html
    if limit: 
      limitclause = "LIMIT %s" % (limit,)
    else:
      limitclause = ""
    qry += " OFFSET %s %s" % (offset, limitclause)
  return qry

def FindFiles(conditions, attributes=[], offset=0, limit='all', sorted=False):
  ''' Retrieve values of attributes for resources satisfying conditions'''
  qry = ValueQuery(conditions, attributes)
  qry = PagedQuery(qry, offset, limit, sorted)
  if qry: 
    return db.execQuery(qry)
  else:
    return []

# ValidValues :: [Condition] -> Prop -> [Value]
def ValidValues(conditions, property, offset=0, limit='all', sorted=False):
  ''' Retrieve values of property for resources satisfying conditions.'''
  tuples = FindFiles(conditions, [property], offset, limit, sorted)
  results = [t[0] for t in tuples]
  return results

def PathProperties(path, conds):
  '''Retrieve unique properties for resources that 1) satisfy conditions and 2)
are avilable in the path context provided.'''

  raw = "PathProperties(%s, %s)" % (path, conds)
  qlog.info(raw) 
  try:
    callstr = pattre.sub('_', raw)
 
    start_time = time.time()
    if iscached(callstr):
      tuples = getCachedResults(callstr)
      updateCache(callstr)
      results = ('', [t[0] for t in tuples])
    else:
 
      # ----------------
      if not path:
        props = ValidProps(conds)
        results = '', props
      elif not conds:
        results = PropertiesOf(TraverseQuery(path), True)
      else: 
        newpath = path + [(conds, 'userkey')]
        results = Traverse(newpath)
       # ---------------- 
      t = time.time() - start_time 
      if t > INTERACTIVE_SPEED and not iscached(callstr): 
         cacheQuery(callstr, results[1]) 
      qlog.debug(str(results)) 
      qlog.info("----- finished in: %f secs" % (t,)) 
    
    return results
  
  except Exception, e:
    (et,v,t) = sys.exc_info()
    qlog.ExceptionMessage(et,v,t)
    raise


def PathValues(path, conditions, property, offset=0, limit='all', sorted=False):
  '''Retrieve values of property for resources that 1) satisfy conditions and 2)
are avilable in the path context provided.'''

  raw = "PathValues(%s, %s, %s)[%s,%s]%s" % (path, conditions,property,offset,limit,sorted)
  qlog.info(raw)
  try:
    callstr = pattre.sub('_', raw)

    start_time = time.time()
    if iscached(callstr):
      tuples = getCachedResults(callstr)
      updateCache(callstr)
      results = [t[0] for t in tuples]
    else:

      # ----------------
      if not path:
        results = ValidValues(conditions, property, offset, limit, sorted)
      else:
        newpath = path + [(conditions, property)]
        q = TraverseQuery(newpath)
        q = PagedQuery(q, offset, limit, sorted) 
        tuples = db.execQuery(q)
        tuples = asList(tuples)
        results = [t[0] for t in tuples]
       # ----------------
      t = time.time() - start_time
      if t > INTERACTIVE_SPEED and not iscached(callstr):
         cacheQuery(callstr, results)
      qlog.debug(str(results))
      qlog.info("----- finished in: %f secs" % (t,))

    return results

  except Exception, e:
    (et,v,t) = sys.exc_info()
    qlog.ExceptionMessage(et,v,t)
    raise

class gensym:
  def __init__(self): 
    self.symbol = 0

  def currid(self):
    return "p%s" % (self.symbol,)

  def nextid(self):
    self.symbol += 1
    return self.currid()

# [Resource] -> [Property]
# where [Resource] is represented as a SQL statement returning userkeys
def PropertiesOf(sql, multivalued=False):
  if not sql: return 0, []

  if multivalued: 
    sigsql = '''
    select r.signature, sum(k.cnt) as cnt
    from resource r, ( 
      %s 
    ) k
    where k.userkey = r.userkey
    group by r.signature
''' % (sql,)

    coolsigsql = '''
select distinct array_to_relation as property 
from array_to_relation((
  select array_accum_cat(string_to_array(signature, ','))
  from (
%s
  ) sigarray
))
''' % (sigsql,)

    rs = db.execQuery(sigsql)
    
  else:
    # Use a JOIN
    sigsql = '''
SELECT signature, count(userkey) as cnt 
  FROM resource 
 WHERE userkey IN (%s)
GROUP BY signature
''' % (sql,)
    rs = db.execQuery(sigsql)

  if not rs: return 0, []
  sigs, cs = zip(*rs)
  cnt = sum(cs)

  ss = [set(s.split(',')) for s in sigs]
  if not ss: return 0, []

  result = ss[0]
  for s in ss[1:]:
    result |= s

  # all resources should have the the userkey property
  result.add('userkey')
  return cnt, asList(result)

def UnNest(sql, column='userkey', counts=True):
  colname = signature.safename(column)
  if counts: 
    cnt = ', count(*) as cnt'
  else:
    cnt = ''

  unnest = '''
      select array_to_relation as userkey%s
      from array_to_relation((
        select array_accum_cat(string_to_array(x.%s, '%s'))  as arr
        from (%s) x
      ))
      group by array_to_relation
''' % (cnt, colname, config.db_multivalue_delimiter, sql)
  return unnest

def TraverseQuery(path):
  
  def makepair(C, p):
    return ValueQuery(C, ['userkey', p]), p

  safe = signature.safename
  qps = [makepair(C, p) for C, p in path]
  qps = [(q,p) for q,p in qps if q]

  '''
  
  qs, ps = zip(*qps)

  selc = "SELECT r%s.%s FROM %s WHERE %s"
  fromc = "(%s) r%s"
  wherec = "r%s.%s = r%s.%s"
  
  From = ", ".join([fromc % (UnNest(q, p),i) for i, (q,p) in enumerate(qps)])
  if len(ps) == 1:
    Where = ""
  else:
    pairs = enumerate(zip(ps[:-1], ps[1:]))
    Where = " AND ".join([wherec % (i,p1,i+1,p2) for i, (p1, p2) in pairs])

  sql = selc % (len(ps) -1 , ps[-1], From, Where)
  sys.exit()
  '''

  leaf = "SELECT %s FROM (%s) x"
  internal = "SELECT %s FROM (%s) x WHERE userkey IN (%s)"

  def subqry(qps, counts=False):
    if not qps: return ""
    q, p = qps.pop()
    sp = signature.safename(p)
    if qps:
      return UnNest(internal % (sp, q, subqry(qps)), p, counts) 
    else:
      return UnNest(leaf % (sp, q), p, counts)
   
  sql = subqry(qps, True)
  return sql

def Traverse(path):
  return PropertiesOf(TraverseQuery(path), True)

# ValidProps :: [Condition] -> [Prop]
def ValidProps(conditions):
    uniqueconditions = set([tuple(xs) for xs in conditions])
  
    result = set()
    attrs = dict(conditions).keys()
    matches = sm.MatchingSignatures(attrs)
    for s in matches:
      q = s.ConjunctiveQuery(conditions, "*", distinct=False)
      if db.Exists(q):
          result = result | set(s.rawcolumns())
    seq = asList(result)
    return seq

# Describe :: FileId -> Description
def Describe(key): 
  qlog.info("Describe(%s)" % (key,))
  for s in sm.UniqueSignatures():
    q = s.ConjunctiveQuery(conditions=[('userkey', key)], wildcard=False)
    rs = db.execQuery(q);
    if len(rs) != 0:
      break
  
  if len(rs) == 0:    
    raise ValueError("no resource '%s' was found" % (key,))
  else:
    qlog.debug("columns: %s" % (s.rawcolumns(),))
    return zip(s.rawcolumns(), [str(x) for x in rs[0]])    

