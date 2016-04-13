
_page = '''
<HTML>
  <TITLE>%s</TITLE>
<BODY>
%s
</BODY>
</HMTL>
'''

def simplepage(title, content):
  return _page % (title,content)

def asString(attrs):
  return ' '.join(['%s="%s"' % (a,v) for a,v in attrs])

def horizontal(columns):
  table = '''
<table>
<tr>
%s
</tr>
</table>
'''
  columnformat = '''  <td valign="top">%s</td>'''

  row = "\n".join([columnformat % (html,) for html in columns])

  return table % (row,)

def vertical(rows):
  table = '''
<table>
%s
</table>
'''
  rowformat = '''   
<tr valign=top>
  <td>%s</td>
</tr>
'''

  column = '\n'.join([rowformat % (html,) for html in rows])

  return table % (column,)

def grid(columncount, cellvalues, cellattrs=[], fontattrs=[]):
  columncount = int(columncount)
  table = """
<table>
  %s
</table>
"""
  rowformat = """   
<tr>
  %s
</tr>
"""
  columnformat = '''
  <td %s><span %s>%s</span></td>
''' % (asString(cellattrs), asString(fontattrs), "%s")

  n = len(cellvalues)
  rowcount = n // columncount + 1

  def rowslice(rownum):
    i = rownum * columncount
    j = i + columncount 
    if j > n: j = n
    return cellvalues[i:j]

  def makerow(columnvalues):
    return [columnformat % (cv,) for cv in columnvalues]
 
  rows = ['\n'.join(makerow(rowslice(i))) for i in range(rowcount)]
  rowcontent = '\n'.join([rowformat % (row) for row in rows])

  return table % (rowcontent,) 
