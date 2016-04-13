import operator as ops
from mod_python import apache
from mod_python import util
from mod_python import Session

import xmlrpclib as xrl
import htmllayout as html
import math

import os.path

server = xrl.Server("http://amb25.stccmop.org:8666")

config = server.ConfigInfo()
DB_DELIM = config["db_multivalue_delimiter"]
ASCII_INGEST_DELIM = config["ascii_ingest_field_delimiter"]
TITLE = "Quarry Property Explorer"
PAGESIZE = 150

def id(x):
  return x

def transform(lst, seed=[], map=id, fold=ops.concat):
  return reduce(fold, [map(x) for x in lst], seed)

pageformat = '''
<html>
<head>
<TITLE>%s</title>
<style type="text/css">
body {background-color: #DDDDDD}
H2 {font-size: 18pt; font-family: arial}
H3 {font-size: 14pt; font-family: arial}
span.bright {font-size: 18pt; font-family: arial; color: #0000FF}
</style>
</head>
<body>
<table>
  <tr>
    <td valign='top'>
<H2><span class=bright>Q</span>uarry <br> <span class=bright>P</span>roperty <br> <span class=bright>E</span>xplorer</H2>

<br><br><br>

<h5><i><a href='doc'>what is this?</a></i></h5>

<p><p>

<h4><a href='clear'>start over</a></h4>

<p><p>

<h5><a href='signatures'>show signatures</a></h5>

<p><p>

<form action='describe'>
<input name='userkey' size='12' value='jump to userkey'></input><input type='submit' value='Go'/>
</form>

<p><p>

<!-- <h5><a href='uploadTriples'>Upload Triples</a></h5> -->



    </td>
    <td width="1" bgcolor="#0000FF"><BR></td>
    <td width="5"><BR></td>
    <td border=1 valign='top'>
    <div style="width: 30em;" class="content">%s</div>
    </td>
  </tr>
</table>
</body>
</html>
'''

leftright = '''
<div style="width: 20em; float: left;" class="result">%s</div>
<div style="width: 10em; float: right;" class="path">%s</div>
'''

def makepage(body):
  return pageformat % (TITLE,body)

def getSimplePath(req):
  path = getPath(req)
  return [(C,p) for C,p,cnt in path]

def getPath(req):
  sess = Session.Session(req, lock=0)
  path = sess.get('path', [])
  return path

def setPath(req, path):
  sess = Session.Session(req, lock=0)
  sess['path'] = path
  sess.save()
  sess.unlock()

def makeresultpage(result, path=[]): 
  pathdisplay = ""
 
  for cs, t, cnt in path:
    C = ", ".join(["%s=%s" % c for c in cs]) or "(all)"
   
    C = '''<div style="text-align: center; margin-left:auto; margin-right:auto; background-color:#EEEEEE">%s</div>''' % (C,)
    T = '''<div><div style="padding-top:1.5em; margin-left:auto; margin-right:auto; height:3em; width:1em; background-color:#EEEEEE"><em>%s (%s)</em></div>''' % (t,cnt)
    pathdisplay += C + T
  
  body = leftright % (result, pathdisplay)
  return makepage(body)
    
def doc():
  body = '''
Quarry Property Explorer is direct interface to the Quarry metadata repository.  It's purpose is to 
<ol>
<li>Allow domain users to explore their resources without the up-front cost of developing data-dependent custom web interfaces.</li>
<li>Provide a canonical example of an application based on the Quarry API.</li>
<li>Allow quarry developer(s) to debug the API</li>
</ol>
The Quarry system itself is 
<ol>
<li>an RDF store, for efficiently managing millions of triples</li>
<li>a Dataspace Indexer and Profiler, for exploring unfamiliar, "green field" dataspaces</li>
<li>a semi-automated metadata harvester for organizing and indexing filesystem data</li>
</ol>
<p>
To use the system, you alternatively select properties and values, progresively building a conjunctive query to narrow search.  To see a list of resources that match the current criteria, select the 'userkey' property.
<p>
The initial view is a unique list of all metadata descriptors harvested by the system.  Selecting a property <i>A</i> returns the unique values found for that property in the system, [<i>A</i>].  Selecting a value <i>v</i> returns another list of properties.  Every property in the new list is guaranteed to be associated with at least one file <i>f</i> such that (<i>A</i>, <i>v</i>) is in the set D(<i>f</i>), where D(<i>x</i>) is the set of (property, value) pairs associated with a file <i>x</i>.  Now that everything is crystal clear, you can begin using the system.
<p>
The model is a large tree, with resources at the leaves and properties and values as internal nodes.  Properties are at odd numbered depths and values are at even numbered depths.  At each level, all the resources that meet the condition are attached as leaves.  Materializing the entire logical tree would be wildly redundant and expensive, but navigating down a path at a time is efficient and fairly intuitive.
'''
  return pageformat % (TITLE, body)
  
import xmlrpclib as xrl
import urllib

EMPTY = "__blank__"
EMPTY_HTML = EMPTY #"&lt;blank&gt;"

def display(x):
  return x or EMPTY

def undisplay(x):
  if x == EMPTY:
    return ""
  else:
    return x

def encode(val):
  # cleans data for passing through http
  ans = urllib.quote_plus(display(val))
  return ans

def unencode(encval):
  ans = undisplay(urllib.unquote_plus(encval))
  return ans

def signatures(req):
  cnt = server.Count()
  sigs = server.Signatures()
  header = '''
  <table>
  <tr><td valign='top'>%s Signatures, %s Resources, %s Descriptors<p></td></tr>
  <tr height=1 bgcolor=#0000FF><td/></tr>
  <tr height=10><td/></tr>
  </table>
  ''' % tuple(cnt)

  def showsig(s):
    return "%s <br><br>" % s

  body = transform(sigs, "", showsig)

  return makepage(header + body)
    
def mkvallinker(qs, prop):
  # returns a function for formatting values as HTML links to ValidValue queries
  def mkproplink(val):
    link = "<a class=proplink href='showprops?%s'><i>%s</i></a>"
    urlval = encode(val)
    displayval = display(val)
    fullqs = "%s&%s=%s" % (qs, encode(prop), urlval)
    return link % (fullqs,displayval)
  
  def mkfilelink(val):
    link = "<a class=proplink href='describe?userkey=%s'><i>%s</i></a>"
    return link % (encode(val), display(val))

  if prop.lower() == "userkey":
    mklink = mkfilelink
  else:
    mklink = mkproplink

  return mklink

def uploadTriples(req):
  format = '''
    <form method="post" action="loadASCIITriples" enctype="multipart/form-data">
    Upload ASCII triples of the form 'userkey&lt;delim>property&lt;delim>value\\n' 
    where &lt;delim> = <input name='delim' type='text' width='1' value='%s'/>.<br><br>
    <input type='file' name='triples'/>  <input type='submit' value='Upload'/>
    </form>
  '''
  return makepage( format % (ASCII_INGEST_DELIM,))
   

def loadASCIITriples(req, triples, delim):
  content = triples.read()
  response = server.LoadASCIITriples(content, delim)
  return uploadTriples(req)

def describe(req):
  conditions = util.parse_qs(req.args)
  key = conditions["userkey"][0]
  
  pairs = server.Describe(key)
  
  def mkdescriptor(pair):
    prop, val = pair
    mkvallink = mkvallinker("", prop)
    formattedval = "|".join([mkvallink(v) for v in val.split(DB_DELIM)])
    format = "<input name='%s' value='%s' type='checkbox'/>%s = %s<br><br>"
    return format % (prop, val, prop, formattedval)

  body = transform(pairs, "", mkdescriptor)
  format = '''
  <table>
  <tr><td valign='top'>All descriptors for resource %s<p></td></tr>
  <tr height=1 bgcolor=#0000FF><td/></tr>
  <tr height=10><td/></tr>
  </table>
  <form action='showprops'>
  Find properties for resources matching checked descriptors: <input type='submit' value='Go'/>
  <p/>
  %s
  </form>
  <div style="float:right"><a class=filelink href='getfile?userkey=%s'><i>%s</i></a></div>
  '''
  return makepage( format % (key,body, key, "Show Resource") )

def getConditions(req):
  if not req.args:
    return None, []
  else:
    args = util.parse_qs(req.args)
    conditions = [(p,v) for (p,vs) in args.items() for v in vs if p != "prop"]
    prop = args.get("prop", [None])[0]
    return prop, conditions
    

def Context(conditions):
 return " and ".join(["%s contains '%s'" % p for p in conditions])

def getfile(req):
  conditions = util.parse_qs(req.args)
  path = conditions["userkey"][0]
  
  root, ext = os.path.splitext(path)
  content = server.GetFile(path)

  if ext == ".gif":
    req.content_type = "image/gif"

  return content.data

def showvals(req):
  prop = ""
  offset = 0
  limit = PAGESIZE
  
  if not req.args:
    conditions = [] 
  else:
    args = util.parse_qs(req.args)
    prop = args.get("prop")[0]  # throws key error if 'prop' not found
    sorted = args.get("sorted", [""])[0] 
    offset = args.get("offset", [0])[0]
    limit = args.get("limit",[PAGESIZE])[0]
    arglst = [(p,v) for (p,vs) in args.items() for v in vs]
    conditions = [(p,v) for (p,v) in arglst 
                      if p != "offset" 
                     and p != "limit" 
                     and p != "sorted" 
                     and p != "prop"]

  realprop = unencode(prop)
  #query strings have a list of values for each keyword
  
  pairs = [(unencode(p),unencode(v)) for p,v in conditions]
  
  path = getSimplePath(req)
  result = server.PathValues(path, pairs, realprop, offset, limit, sorted)

  qs = '&'.join(['%s=%s' % (p, v) for p, v in conditions])
  
  # returns a fuction for formatting values as links to ValidValue queries
  mklink = mkvallinker(qs, prop)
  
  def mkmultivallink(val):
    return ", ".join([mklink(v) for v in val.split(DB_DELIM)]) + "<br><br>\n"

  resultbody = transform(result, "", mkmultivallink)
  
  context = Context(conditions)
  
  format = '''
      <table>
        <tr><td valign='top'>Values %s through %s of <b>%s</b>, for resources where <i>(%s)</i></td></tr>
        %s
        <tr><td>%s</td></tr>
      </table>
'''
  if not sorted and len(result) == PAGESIZE:
    navigation = '<tr><td>These results are just a sample.  <a href="%s">Show all</a></td></tr><p>'
    navigation = navigation % ("showvals?%s&sorted=true&prop=%s&offset=0&limit=%s" % (qs,prop,PAGESIZE),)
    navigation += '<tr height=1 bgcolor=#0000FF><td/></tr>'
    
  elif not sorted and len(result) < PAGESIZE:
    navigation = '<tr height=1 bgcolor=#0000FF><td/></tr>'
    
  elif sorted:
    poff = max(0, int(offset) - PAGESIZE)
    noff = int(offset) + PAGESIZE
    backlink = '<a href="showvals?%s&sorted=true&prop=%s&offset=%s&limit=%s">%s - %s</a>'
    backlink = backlink % (qs,prop,poff,PAGESIZE,poff,poff+PAGESIZE-1)
    fwrdlink = '<a href="showvals?%s&sorted=true&prop=%s&offset=%s&limit=%s">next %s</a>'
    fwrdlink = fwrdlink % (qs,prop,noff,PAGESIZE, PAGESIZE)
    
    if int(offset) == 0: backlink = ''
    if len(result) < PAGESIZE: fwrdlink = ''
      
    navigation = '<tr><td>%s &nbsp;&nbsp;&nbsp; %s</td></tr><p>' % (backlink, fwrdlink)
    navigation += '<tr height=1 bgcolor=#0000FF><td/></tr>'

  else:
    navigation = '<tr height=1 bgcolor=#0000FF><td/></tr>'
    
  #body = html.grid(6, [mklink(r) for r in result])
  tup = (offset,int(offset)+len(result),prop, context,navigation,resultbody) 
  displaypath = getPath(req)
  return makeresultpage(format % tup, displaypath)

def clear(req):
  sess = Session.Session(req, lock=0)
  sess.invalidate()
  del sess
  return showprops(req)

def traverse(req):
  displaypath = getPath(req)

  prop, conditions = getConditions(req)
  
  path = [(cs,p) for cs,p,cnt in displaypath] + [(conditions, prop)]

  cnt, result = server.PathProperties(path, [])
  #return result
  pairs = []
  #result = server.ValidProps(pairs)

  displaypath = displaypath + [(conditions, prop, cnt)]
  setPath(req, displaypath)
  qs = '&'.join(['%s=%s' % (encode(prop), encode(val)) for prop, val in pairs])

  def mklink(p):
    return '''<a class=vallink href='showvals?%s&prop=%s'><b>%s</b></a> (<a href="traverse?%s&prop=%s"><i>traverse</i></a>)<br><br>\n''' % (qs,encode(p),encode(p),qs,encode(p))

  context = Context([])

  format = '''
  <table>
  <tr><td valign='top'>Properties of resources where <i>(%s)</i><p></td></tr>
  <tr height=1 bgcolor=#0000FF><td/></tr>
  <tr height=10><td/></tr>
  </table>
  %s
  '''
  body = transform(result, "", mklink)

  return makeresultpage(format % (context, body), displaypath)

def showprops(req):
  prop, conditions = getConditions(req)
  #query strings have a list of values for each keyword
  pairs = [(unencode(p), unencode(v)) for p,v in conditions]
  
  path = getSimplePath(req)

  cnt, result = server.PathProperties(path, pairs)
  qs = '&'.join(['%s=%s' % (encode(prop), encode(val)) for prop, val in pairs])
  
  def mklink(p):
    return '''<a class=vallink href='showvals?%s&prop=%s'><b>%s</b></a> (<a href="traverse?%s&prop=%s"><i>traverse</i></a>)<br><br>\n''' % (qs,encode(p),encode(p),qs,encode(p))
    
  context = Context(conditions)
  
  format = '''
  <table>
  <tr><td valign='top'>Properties of %s resources %s where <i>(%s)</i><p></td></tr>
  <tr height=1 bgcolor=#0000FF><td/></tr>
  <tr height=10><td/></tr>
  </table>
  %s
  ''' 
  body = transform(result, "", mklink)
  #body = html.grid(6, [mklink(r) for r in result])

  msg = ""
  if path: msg = "in the path context at right"

  return makeresultpage( format % (cnt, msg, context, body), getPath(req))


def index(req):
  req.headers_out['Location'] = "%s/showprops"  %(os.path.basename(req.filename),)
  req.status = apache.HTTP_MOVED_PERMANENTLY
  raise apache.SERVER_RETURN, req.status
