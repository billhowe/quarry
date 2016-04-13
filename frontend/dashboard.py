import xmlrpclib as xrl
import htmllayout as html
import math

import os.path, sys

quarry = xrl.ServerProxy("http://amb38.ccalmr.ogi.edu:8000")

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
<H2><span class=bright>Q</span>uarry <br> <span class=bright>D</span>ashboard </H2>

    </td>
    <td width="1" bgcolor="#0000FF"><BR></td>
    <td width="5"><BR></td>
    <td border=1 valign='top'>
    
    <table>
      <tr>
        <td>Harvest</td> <td>Load</td> <td>Organize</td>
      </tr>
      <tr>
        <td><input type="text"/> </td>
        <td><input type="text"/> </td>
        <td><input type="text"/> </td>
      </tr>
    </table>
    
    </td>
  </tr>
</table>
</body>
</html>
'''


