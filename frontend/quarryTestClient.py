
import xmlrpclib as xrl

#server = xrl.ServerProxy("http://amb38.ccalmr.ogi.edu:8000")
server = xrl.ServerProxy("http://127.0.0.1:8888")

def testclear():
  path = []
  conds = []
  # ps = server.PathProperties(path, conds)
  ps = server.PathValues(path, conds, 'animation')
  print ps

def testpath2():
  path = [([('variable', 'TEM'), ('animation', 'anim-am169')], 'userkey')]
  conditions = []
  prop = 'animation'
  #conditions = [("plottype", "isosal")]
  #conditions = []
  #ps = server.PathProperties(path, conditions)
  ps = server.PathValues(path, conditions, prop)
  print ps

def containstest():
  path = [([], "contains")]
  conditions = []
  ps = server.PathProperties(path, conditions)
  print ps

def twopath():
  path = [([], "has_dose_form"), ([], "dose_form_of")]
  path = [([], 'has_dose_form')]
  property = 'TTY'
  ps = server.PathValues(path, [], property)
  print ps

def testpath():
  #path = [([("aggregate", "bottom"), ("region", "plume")], "userkey")]
  #conditions = [("plottype", "isosal")]
  #ps = PathProperties(path, conditions)
  #ps = server.PathValues(path, conditions, 'day')
  path = [([('variable', 'TEM'), ('animation', 'anim-am169')], 'userkey')]
  conditions = [('animation', 'anim-am169')]
  prop = 'animation'
  ps = server.PathProperties(path, conditions)
  print ps

containstest()
#print server.ValidProps([])
#print server.ValidValues([], "animation")
#img = server.GetFile("/home/workspace/ccalmr/forecasts/forecasts_ref/2005/2005-003/images/transsal_channel_transects/anim-sal_channel_transects.gif")

#f = file("foo.gif", "w")
#f.write(img.data)
