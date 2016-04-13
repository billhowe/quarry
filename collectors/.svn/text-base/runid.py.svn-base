#!/usr/local/bin/python

# Extracts metadata from a .63 binary output file
# for use with the 'reflector' metadata facility

import sys
import re
import additem

AddItem = additem.AddItem

args = sys.argv

if len(args) < 2:
  print "supply a path from which to extract a runid...."
  sys.exit(1)

path = sys.argv[1]

p = re.compile('''\/(20|19)\d\d-[0-5]\d-\d\d\/''')
m = p.search(path)
if m:
  runid = m.group()[1:-1]
  AddItem('RunId', str(runid), '<year>-<week>-<database id>', 'string')
  AddItem('Year', str(runid)[:4], 'Year, derived from runid', 'integer')
  AddItem('Week', str(runid)[5:7], 'Week, derived from runid', 'integer')
  AddItem('DatabaseId', str(runid)[-2:], 'Database Id, derived from runid', 'integer')

q = re.compile('''\/(20|19)\d\d-\d\d\d\/''')
m = q.search(path)
if m:
  runid = m.group()[1:-1]
  AddItem('RunId', str(runid), '<year>-<day>', 'string')
  AddItem('Year', str(runid)[:4], 'Year, derived from runid', 'integer')
  AddItem('Day', str(runid)[5:8], 'Day, derived from runid', 'integer')

