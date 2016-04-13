#!/usr/local/bin/python2.3

import sys, popen2, re
import qdb, queries, config
import qlog 
import config
import time

DELIM = ';'

patt = '''(\'|\\\|;|\n)'''
p = re.compile(patt)

class BulkLoader:

    def __init__(self, db=qdb.quarrydb()):
      self.openFiles('a')
      sql = '''SELECT max(id) from resource_stage'''
      x = db.execQuery(sql)[0][0]
      self.currentId = x or 0
      assert isinstance(db, qdb.quarrydb)
      self.qdb = db
 
    def truncateFiles(self):
      self.closeFiles
      self.openFiles('w+')
      self.closeFiles

    def openFiles(self, mode):
      s = self
      s.fresource = file(config.tmpdir + config.resourceFileName, mode)
      s.fdescr = file(config.tmpdir + config.descriptorFileName, mode)

    def closeFiles(self):
      self.fresource.close()
      self.fdescr.close()

    def addresource(self, filename):
      self.currentId = self.currentId + 1
      self.fresource.write(str(self.currentId) + DELIM + filename + '\n')
          
    def adddescriptor(self, (name, value, descr, type)):
      rec = DELIM.join([str(self.currentId), 
                        name, 
                        p.sub('''\\\\\g<1>''', value),
                        descr, 
                        type]) + '\n'
      self.fdescr.write(rec)

    def loadharvest(self, dir=config.datadir):

      '''Uses psql to stage harvested data in the quarry database'''

      qlog.info("Loading harvest from %s" % (dir,))
      t = time.time()

      sql = "%s;\n %s;\n %s;\n %s;" % ("begin transaction",
                                       queries.load_resources(dir), 
                                       queries.load_descriptors(dir),
                                       "commit")
      sqlfile = config.tmpdir + "/temp.sql"
    
      f = file(sqlfile, "w")
      f.write(sql)
      f.close()
      
      self.closeFiles()
      cmd = '''%s -h %s -f "%s" %s''' % (config.psqlpath, 
                                         self.qdb.hostname, 
                                         sqlfile, 
                                         self.qdb.dbname)

      flusher = popen2.Popen3(cmd)
      output = flusher.fromchild
      # don't quit till this process finishes
      qlog.debug('psql response:\n' + output.read())
      flusher.wait()
      
      qlog.info("...bulk loaded in %s seconds." % (time.time() - t,))

    def LoadTriples(self, fname):
      '''Load triples from an ASCII file.  Use config.py to configure delimiters'''

      # TODO: support RDF and N-triples format, at least
      t = time.time()

      qlog.info("Loading triples from %s" % (fname,))
      cmd = '''%s -h %s -c "%s" %s''' % (config.psqlpath, 
                                         self.qdb.hostname, 
                                         queries.copy_triples(fname, csv=""), 
                                         self.qdb.dbname)
      flusher = popen2.Popen3(cmd)
      output = flusher.fromchild
      # don't quit till this process finishes
      qlog.debug('psql response:\n' + output.read())
      flusher.wait()
      
      qlog.info("...triples loaded in %s seconds." % (time.time() - t,))

def main():
  t = time.time()
  b = BulkLoader() 
  if len(sys.argv) > 1:
    #b.loadharvest(sys.argv[1])
    b.LoadTriples(sys.argv[1])
  else:
    #b.loadharvest()
    b.LoadTriples(config.triplefile)

  print "loaded in %s seconds" % (time.time() - t,)
if __name__ == '__main__':
  main()
