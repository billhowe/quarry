
import sys
sys.path += ".."

from quarry import *

def testclear():
  print PathProperties([],[])

def Daves():
  ps = ValidProps([])
  print ps

def testpath():
  path = []
  #path = [([("aggregate", "bottom"), ("region", "plume")], "userkey")]
  #conditions = []
  #conditions = [("plottype", "isosal")]
  #conditions = []
  path = [([('variable', 'TEM'), ('animation', 'anim-am169')], 'userkey')]
  conditions = [('animation', 'anim-am169')]
  prop = 'animation'
  print PathValues(path, [], 'region')

def testpath2():
  #ps = PathValues(path, [('TTY', 'DF')], property)
  path = [([], "contains")]
  conditions = []
  #ps = PathProperties(path, conditions)
  ps = PathValues(path, conditions, "TTY")
  print ps

def testpath1():
  #path = [([("TTY", "CD")], "dose_form_of"), ([("TTY", "DF")], "userkey")]
  #path = [([], "has_dose_form"), ([], "dose_form_of")]
  path = [([], "dose_form_of")]
  property = 'TTY'
  #c, rs = Traverse(path)
  #ps = PathValues(path, [], property)
  #ps = PathProperties(path, [('TTY', 'DF')])
  ps = PathProperties(path, [])
  print ps

def testrels():
  #ps = PathProperties([], [('SAB','RXNORM')])
  ps = PathValues([], [], "SAB")
  print ps 

 # xs = ValidValues(join, "userkey")
def main():
  #descrs = dict([('dim', '3')])
  t = time.time()
  #badjoin = [("SUBSETMEMBER","319032~1~"),("LANGUAGECODE", "en-US"),("DESCRIPTIONTYPE",'0'), ("INITIALCAPITALSTATUS",'1'), ("CONCEPTSTATUS",'0')]
  join = [('VA_CLASS_NAME', '[DE820] ANTIPSORIATICS,TOPICAL')]
  ps = ValidProps([])
  print ps
 # xs = ValidValues(join, "userkey")
  #xs = Describe('/home/workspace/ccalmr/hindcasts/bin/intel/CruiseImages/2002-19-vv73a/images/cruise_images/CRcms01_cd2325_ctcast_sal_cont.gif')
  #xs = ValidValues([("VA_GENERIC_NAME", "ABACAVIR")], "TTY")
  xs = ValidValues([], "tty")
  print xs
  print time.time() - t
  #xs = ValidProps([])
  #for s in sm.UniqueSignatures():
  #  print s.columns()
  #xs = ValidValues([], "UMLSAUI", 5, 105, True)
  #xs = ValidValues([('year', '2004')], 'plottype')
  #xs = ValidValues([("animation","anim-tansy")], "instrumentcomparison")
  #xs = ValidProps([("NDC","00003055341")])
  #xs = ValidValues([("NDC","00003055341")], 'NDC')
  #xs = ValidProps([('dramp','2.')])
  #xs = ValidValues([], "station")
  #xs = ValidValues([], "version")
  print "returned in %s seconds" % (time.time() - t,)
  #print xs
  
def queryErr():
  sql = '''SELECT * FROM sig817'''
  print db.execQuery(sql)

def describetest():
  print Describe('/home/workspace/ccalmr/forecasts/da/2007-198/images/cruise_images/CRcms01_cd4216_ctcast_0921a_summary.gif')

if __name__ == '__main__':
  qlog.DebugOn()
  #describetest()
  main()
  #queryErr()
  #Daves()
  #testpath()

