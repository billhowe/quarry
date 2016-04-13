import signature, qdb, qlog, queries, config
import sys, time

class SignatureManager:
  def __init__(self, db=qdb.quarrydb()):
    self.qdb = db

  def ReapHarvest(self):
    qlog.info("Reaping harvest (computing signatures)")
    t = time.time()
    
    self.qdb.execCommand('begin transaction;')
    try: 
      #self.DeleteExistingResources()
      self.ComputeResourceSignatures()
      self.DispatchNewResources()
      self.ClearStagingArea()
      self.ClearCache()
    except: 
      (e, v, t) = sys.exc_info()
      qlog.critical(str(e) + ": " + str(v))
      self.qdb.execCommand('rollback;')
      # re-raise the error; it's probably fatal
      raise e, v, t
      return False 
    else:
      self.qdb.execCommand('commit;')
      qlog.info("...reaped in %s seconds." % (time.time() - t,))
      return True

  def ProcessTriples(self):
    # some data may have been loaded as raw triples
    # load these into the staging area
    t = time.time()
    qlog.info("Processing Triples...")
    qr = queries.resources_from_triples
    self.qdb.execCommand(qr)
    qlog.info("...extracted resources in %s seconds." % (time.time() - t,))
    
    t = time.time()
    qd = queries.descriptors_from_triples(config.db_multivalue_delimiter)
    self.qdb.execCommand(qd)
    qlog.info("...extracted descriptors in %s seconds." % (time.time() - t,))

  def CountDescriptors(self):
    dcount = 0
    rcount = 0
    scount = 0
    for sig in self.UniqueSignatures():
      c = sig.Cardinality()
      dcount += (c * (len(sig.scheme())-2))
      rcount += c
      scount += 1
    return (scount, rcount, dcount)

  def ClearCache(self):
    try:
      self.qdb.execCommand(queries.drop_query_cache)
    except qdb.pg.ProgrammingError:
      pass
    self.qdb.execCommand(queries.create_query_cache)

  def ClearStagingArea(self):
    qlog.debug("Clearing Staging Area")
    self.qdb.execCommand(queries.delete_staging_area)

  def ClearSignatures(self):
    qlog.debug("Clearing all Signatures")
    for s in self.UniqueSignatures():
      s.DropExtent()
      s.DeleteSignature()

  def DeleteExistingResources(self):
    qlog.debug("Deleting Existing Resources")
    # need to find all the resources previously dispatched
    # that are staged to be re-dispatched, and delete them
     
    #self._DeleteFromSignatureExtents()
    
    # resource table is deprecated
    #self._DeleteResources()
    pass

  def ComputeResourceSignatures(self):
    qry = queries.update_resources_with_signatures
    self.qdb.execCommand(qry)

  def DispatchNewResources(self):
    qlog.debug("Dispatch New Resources")
    self._RefreshUniqueSignatures()
    for s in self.UniqueSignatures():
      qlog.info("Computing extent for signature %s"%(s,))
      s.ComputeExtent()

    # resource table is deprecated
    self._InsertNewResources()
 
  def MatchingSignatures(self, attributes):
    '''Return all signatures containing the given attributes'''
    return [S for S in self.UniqueSignatures() if set(attributes) <= set(S.rawcolumns())]
 
  def UniqueSignatures(self):
    qry = queries.signature_star
    rawsigs = self.qdb.execQuery(qry)
    for id, ps in rawsigs:
      yield signature.Signature(id, ps, self.qdb)

# -------- Private ---------

  #def _DeleteFromSignatureExtents(self):
  #  ''' 
  #  create temp table known as (
  #  select r.userkey, r.signature 
  #    from resource_stage rs, resource r
  #   where r.userkey = rs.userkey
  #   )
  #  '''
  #  results = '''
  #    select distinct signature from known
  #  '''
  #  for (sigx,) in results:
  #    q = '''delete from sigx where sigx.userkey = known.userkey'''  
    
  #def _DeleteResources(self):
  #  delete from resources where userkey = resource_stage.userkey
  def _RefreshUniqueSignatures(self):
    qry = queries.new_signatures
    self.qdb.Insert("signature",qry)
    sql = "SELECT count(*) from signature"
    S = self.qdb.execQuery(sql)[0][0]
    qlog.info("Found %s unique signatures" % (S,))

  def _InsertNewResources(self):
    qry = queries.insert_new_resources
    self.qdb.execCommand(qry)


def main():
  start = time.time()
  self = SignatureManager()
  self.ProcessTriples()
  self.ReapHarvest()

  print "Resources dispatched in %s seconds." % (time.time() - start,)

if __name__ =='__main__':
  main()
