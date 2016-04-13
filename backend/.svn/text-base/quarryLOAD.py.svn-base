import qdb, harvest, bulkloader, sigmanager, qlog
import os, sys, time, re

def LoadByRegEx(coriedir="/home/workspace/ccalmr/forecasts/forecasts_ref/2004/", regexp='2004-004'):
                        
  qlog.info("Starting load job on %s/%s" % (coriedir, regexp))
  t1 = time.time()
  
  # a regexp for catching only real run dirs
  e = re.compile(coriedir+regexp)

  paths = []
  for root, dirs, files in os.walk(coriedir):
    exists = [root+d for d in dirs if os.path.exists(root+d)]
    paths += [p for p in exists if e.match(p)]
 
  db = qdb.quarrydb()

  h = harvest.Harvester()
  b = bulkloader.BulkLoader(db)
  b.truncateFiles()
  sm = sigmanager.SignatureManager(db)

  for p in paths:
    h.harvestDir(p, b)

  b.closeFiles()
  b.loadharvest()

  sm.ReapHarvest()

  qlog.info("Load job finished in %s seconds." % (time.time() - t1,))

def main():
  if len(sys.argv) < 2:
    print "Usage: python quarry.py <directory to harvest and process>"
    sys.exit()

  dir = sys.argv[1]

  if len(sys.argv) < 3:
    LoadOneDir(dir)
  else:
    reg = sys.argv[2]
    LoadByRegEx(dir, reg)
  
def LoadOneDir(dir):
  h = harvest.Harvester()
  b = bulkloader.BulkLoader()
  sm = sigmanager.SignatureManager()

  b.truncateFiles()
  
  t1 = time.time()
  h.harvestDir(dir, b)
  print "   harvested in %s seconds." % (time.time() - t1,)

  t = time.time()
  b.loadharvest()
  print "   loaded in %s seconds." % (time.time() - t,)

  t = time.time()
  sm.ReapHarvest()
  print "   processed in %s seconds." % (time.time() - t,)

  print "Finished in %s seconds." % (time.time() - t,)

if __name__ == '__main__':
  main()

