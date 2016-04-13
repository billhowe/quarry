import qdb
import qlog
import queries

def safename(name):
   badchars = ['/', ';', '%', '.', ' ', '\\', ':', '|', ')','(']
   for b in badchars:
     name = name.replace(b, '_') 
   if name == "":
     name = "__blank__"
   return '"%s"' % (name,)

class Signature:

  def __init__(self, id, ps, db=qdb.quarrydb()):
    if not isinstance(db, qdb.quarrydb):
      raise TypeError, "1st argumnent must be a metadb (%s)" % str(db)

    if isinstance(ps, type([])):
      self.properties = ps
    elif isinstance(ps, type('')):
      self.properties = ps.split(',')
    else:
      raise TypeError, "2nd argument must be a list of properties or a comma delimited string of properties."

    self.qdb = db
    self.id = id
    self.strid = 'sig'+str(id)

  def Cardinality(self):
    qryformat = "SELECT count(*) FROM %s;"
    q = qryformat % self.strid
    c = self.qdb.execQuery(q)[0][0]
    return c

  def __repr__(self):
    return "%s: (%s)" % (self.id,','.join(self.properties))

  def ComputeExtent(self):
    qlog.debug("Compute Extent for signature %s" % (self.properties,))
    self._makeTable()
    self._populateTable()

  def _makeTable(self):
    '''
Create a table for the signature.  This method is idempotent and non-destructive
    '''
    qlog.debug("Creating table " + self.strid)
    x = self.qdb.checkTable(self.strid)
    if not x:
      fields = self.columns()
      types = ['text']*len(fields)
      self.qdb.createTable( self.strid, fields, types )
    
  def crosstab(self, flds):
    '''
Build a crosstab query that returns a relation with columns defined by allfieldsidsqry should return have a column 'res_id' designating the resources whose descriptors will be loaded. 
These files must match this signature; otherwise the crosstab will fail
    '''
    allfields = self.properties
    innerqry = queries.innerqry(flds)

    innerqry = innerqry.replace("'", "''")
    scheme = self.scheme()
    scheme = ','.join(scheme)
    crossqry = queries.crossqry(innerqry, len(allfields), scheme)
    return crossqry
  
  def _populateTable(self):
    '''
Load a profile table from the staging data.
    '''

    sigid = self.strid
    fields = ','.join(self.properties)
    qlog.debug("Populating Table " + sigid)

    crossqry = self.crosstab(fields)

    # insert into profile table
    scheme = self.columns()
    scheme_s = ','.join(scheme)
    insertqry = "INSERT INTO %s (%s) (%s)" % (sigid, scheme_s, crossqry)
   
    self.qdb.execCommand(insertqry)
    # perhaps we should delete from the staging area as we go...
    # deleteqry = "DELETE FROM metadata WHERE file_id IN (%s)" % idsqry,

  def rawcolumns(self):
    # properties plus userkey, not cleaned
    cols = self.properties
    return ['userkey'] + cols

  def columns(self):
    # properties properly cleaned for use as db column names, plus userkey
    cols = [safename(d) for d in self.properties]
    return ['userkey'] + cols

  def scheme(self):
    return ["userkey text"] + [safename(x) + " text" for x in self.properties] 

  def ConjunctiveQuery(self, conditions, projection_list="*", distinct=False, wildcard=True):
    if wildcard:
      comparison = '''%s LIKE '%%%s%%' '''
    else:
      comparison = '''%s = '%s' '''

    sql_cond = ' AND '.join([comparison % (safename(p), qdb.pg.escape_string(v.replace(",", "%"))) for (p,v) in conditions])

    where_clause = ""
    if sql_cond.strip(): where_clause = " WHERE " + sql_cond
    attrs = ", ".join(['''%s''' % (safename(attr),) for attr in projection_list])

    select = "SELECT"
    #if distinct: select += " DISTINCT ON (%s)" % (attrs,)
    #if distinct: select += " DISTINCT " 

    qry = "%s %s FROM sig%s %s" % (select, attrs, self.id, where_clause)
    if distinct: qry = qry + " GROUP BY %s" % (attrs,)
    return qry

  def DropExtent(self):
    qry = "DROP TABLE sig%s"%(self.id,)
    self.qdb.execCommand(qry)

  def DeleteSignature(self):
    qry = "DELETE FROM signature WHERE tabletag = %s" % (self.id,)
    self.qdb.execCommand(qry)
