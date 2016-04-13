#!/usr/local/bin/python2.3

# Extracts metadata from a .63 binary output file
# for use with the 'reflector' metadata facility

import sys
import struct
import array
import additem

def stub(name, val, descr, type):
  print name, val, descr, type


AddItem = additem.AddItem
#AddItem = stub

args = sys.argv

if len(args) < 2:
  print "supply a 63 file from which to extract metadata...."
  sys.exit(1)

f = file(args[1],'r')

# Read the header
format = "48s48s48s48s48s"
(dataformat,version,starttime,var,vardim) = struct.unpack(format,f.read(240))
format = "ifiiif"
(steps,start,skip,rank,dim,layers) = struct.unpack(format, f.read(24))

AddItem('Version', version.strip(), 'version of the CORIE file format', 'string')
AddItem('Start Time', starttime.strip(), 'Start time of the simulation that generated the file', 'string')
AddItem('Variable', var.strip(), 'The quantity being simulated', 'string')
AddItem('Variable Dimension', vardim.strip(), '2D or 3D, i.e., surface elevation vs. salinity', 'string')
AddItem('Timestep', `steps`, 'timestep', 'float')
AddItem('Skip', `skip`, 'skip?', 'float')
AddItem('Rank', `rank`, '1 = scalar, 2+ = vector', 'float')
AddItem('Dim', `dim`, 'dimension as a float', 'float')
AddItem('Layers', `layers`, 'number of vertical layers', 'float')

# Read the Vertical Grid
(meanSeaLevel,nVerticalLayers) = struct.unpack('fi',f.read(8))
AddItem('Mean Sea Level', `meanSeaLevel`, 'mean sea level', 'float')

# read z-values
zs = struct.unpack(str(nVerticalLayers)+'f', f.read(4*nVerticalLayers))

# Read the Horizontal Grid
(nNodes, nElements) = struct.unpack('ii',f.read(8))
AddItem('Number of Nodes', `nNodes`, 'nodes in the grid found in this file', 'int')
AddItem('Number of Elements', `nElements`, 'elements in the grid found in this file', 'int')
