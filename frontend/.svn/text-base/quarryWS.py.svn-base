
import SimpleXMLRPCServer as serve
import xmlrpclib as xrl
import socket
import quarry
import sys, os
import config

sys.path.append(config.app_path + "/backend/")

import qlog
import queries
import sigmanager

class QuarryServer(serve.SimpleXMLRPCServer):
  def _dispatch(self, method, params):
    try:
      func = getattr(self, 'export_'+ method)
    except AttributeError:
      raise Exception('method %s is not supported' % method)
    else:
      return func(*params)

  def server_bind(self):
    self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    self.socket.bind(self.server_address)            

  def __init__(self, address):
    self.quit = 0
    serve.SimpleXMLRPCServer.__init__(self,addr=address,
                                           logRequests=False)

  def export_ConfigInfo(self):
    configenv = config.__dict__.iteritems()
    return dict([(key, val) for key, val in configenv if '__' not in key])

  def export_ValidValues(self, conditions, property, offset=0, limit=100, sorted=False):
    return quarry.ValidValues(conditions, property, offset, limit, sorted)

  def export_PathValues(self, path, conditions, property, offset=0, limit=100, sorted=False):
    return quarry.PathValues(path, conditions, property, offset, limit, sorted)

  def log_message(self, format, *args):
    qlog.info(format % args)

  def export_ValidProps(self, conditions):
    return quarry.ValidProps(conditions)

  def export_Describe(self, fid):
    return quarry.Describe(fid)

  def export_PathProperties(self, path, conditions):
    qlog.debug("Hello?")
    return quarry.PathProperties(path, conditions)

  def export_Traverse(self, path):
    return quarry.Traverse(path)

  def export_Count(self):
    return quarry.sm.CountDescriptors()

  def export_Signatures(self):
    counts = [(s.Cardinality(), s) for s in quarry.sm.UniqueSignatures()]
    counts.sort(reverse=True)
    return ["(%s) sig%s"%(c,s) for c,s in counts]
    
  def export_GetFile(self, path):
    f = file(path)
    data = f.read() 
    return xrl.Binary(data)

  def export_LoadASCIITriples(self, triples, delim):
    db = config.dbname 
    path = '/tmp/triples.quarry'                                                               
    f = file(path, 'w')
    f.write(triples)
    f.close()
    
    copy = queries.copy_triples
    path = config.psqlpath
                                                                                      
    cmd = '%s -d %s -c "%s"' % (path, db, queries.clear_triples)
    qlog.info('shell command: "%s"' % (cmd,))
    os.system(cmd)
    cmd = '%s -d %s -c "%s"' % (path, db, copy(path, delim))
    qlog.info('shell command: "%s"' % (cmd,))
    os.system(cmd)
                                                                                      
    s = sigmanager.SignatureManager()
    #s.ProcessTriples()
    return True

  def export_Test(self, xs):
    return xs

  def serve_forever(self):
    self.quit = 0
    while not self.quit:
      self.handle_request()

  def export_kill(self):
    self.quit = 1
    self.server_close()
    return 1

if __name__ == "__main__":
  try:
    qlog.info("Starting quarry server....")
    server = QuarryServer((socket.gethostbyname(socket.gethostname()), config.port))
    #server.register_introspection_functions()
    server.serve_forever()
  except KeyboardInterrupt:
    server.export_kill()

                    
