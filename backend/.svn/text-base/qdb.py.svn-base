try: 
  import pg
except: 
  import _pg
  pg = _pg
import sys
import popen2
import config
import qlog as logger 

DELIM = ';'

class quarrydb:
    ''' 
    A simple interface to the metadata database.
    --Provides direct query (with results) and command (no results)
    --Provides a few more specialized methods for the metadata processing application.
    --Provides abstraction of logging, configuration, and errorhandling for the database

    make sure user has permissions in pg_hba.conf on hostname
    '''   

    hostname = config.hostname
#    hostname = 'localhost'
    dbconn = None
    user = config.dbuser
    passwd = config.dbpasswd

    def __init__(self, dbname=config.dbname):
      self.dbname = dbname
      self.connect()

    def execCommand(self, qry):
      '''Executes a SQL statement, ignoring the results'''
      #self.connect()
       # any error handling we should do?
      logger.debug('Executing command: ' + qry)

      #Check to see if the connection is valid
      if (self.dbconn.status != 1):
        logger.info("DB Connection bad, attempting reset")
        self.dbconn.reset()

      result = self.dbconn.query(qry)

    def execQuery(self, qry):
      '''
Executes a SQL statement, returning the results
      '''
      self.connect()
      logger.debug('Executing query: ' + qry)
      qry = qry.strip()
      if not len(qry):
        return []
      # any error handling we should do?
      #print qry
      #x = raw_input()
      #if x == '':
      #  x = qry
      #self.dbconn = None
      #self.dbconn.reset()
      #self.connect()

      #Check to see if the connection is valid
      if (self.dbconn.status != 1):
        logger.info("DB Connection bad, attempting reset")
        self.dbconn.reset()

      response = self.dbconn.query(qry)
      if response: return response.getresult()

    def connect(self):
      if self.dbconn == None:
        self.dbconn = pg.connect (self.dbname, \
                                  self.hostname, \
                                  -1, \
                                  None, \
                                  None, \
                                  self.user, \
                                  self.passwd)

     
    
    def appendTo(self, tablename, qry):
      '''
Append a query's results to a tbale, creating it if it doesn't exist.
     '''
      if self.checkTable(tablename): 
        qry = "INSERT INTO %s (%s)"
      else:
        qry = "CREATE TABLE %s AS (%s);" % (tablename, qry)

      self.execCommand(qry)

    def Insert(self, tablename, qry):
      insert = '''INSERT INTO %s (%s)''' % (tablename, qry)
      self.execCommand(insert)

    def createTableAs(self,tablename, qry):
      '''
Drops and recreates a table based on a query's results.
     '''
      create = "CREATE TABLE %s AS (%s);" % (tablename, qry)

      if self.checkTable(tablename): 
        drop = "DROP TABLE %s; " % tablename
        create = drop + create

      self.execCommand(create)

    def dropTable(self, name):
      if self.checkTable(name):
        drop = "DROP TABLE %s CASCADE;" % name
        self.execCommand(drop)

    def checkTable(self, name):
      '''
returns None if table <name> does not exist
      '''
      check = "select relname from pg_class where relname = '%s'" % name
      result = self.execQuery(check)
      return result
    
    def Exists(self, query):
      (success,) = self.execQuery("Select exists(%s)" % (query,))[0]
      return success == 't'

    def Union(self, queries):
      return "\n UNION \n".join([q.replace(";", "") for q in queries])

    def createTable(self, name, fields, types):
      '''
idempotent table creator.  Returns False if table already existed.
fields is a sequence of string column names and 
types is sequence of string type names. 
      '''
      exists = self.checkTable(name)
      if not exists:
        sql = "CREATE TABLE " + name + "("
        fieldstypes = ['%s %s' % ft for ft in zip(fields, types)]
        sql = sql + ','.join(fieldstypes)
        sql = sql + ')'
      
        self.execCommand(sql)
        return True
      else:
        return False

