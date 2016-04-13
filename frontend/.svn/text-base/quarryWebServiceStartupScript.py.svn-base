#!/usr/bin/env python
# chkconfig: - 85 15
# description: Quarry is a web service for querying CORIE metadata
# processname: python quarryWebService.py
# pidfile: /home/howew/.quarry.pid

import os
import sys
import signal
import os.path
import popen2
import pwd
import grp

QUARRYSERVE = "python /home/quarry/cmop_quarry_prod/frontend/quarryWS.py"
QUARRYPIDFILE = "/home/quarry/cmop_quarry_prod/frontend/.quarry.pid"
QUARRYUSER = "quarry"
QUARRYGROUP = "quarry"

#commented this out and put it below where we fork
#Perhaps change to http://antonym.org/node/100 ? - JGR
#os.setgid(grp.getgrnam(QUARRYGROUP)[2])
#os.setuid(pwd.getpwnam(QUARRYUSER)[2])


def restart(cmd, pidfile):
  stop(cmd, pidfile)
  return start(cmd, pidfile)

def start(cmd, pidfile):
  if os.path.exists(pidfile):
    raise IOError("%s exists, already started?" % (pidfile,))
    
  si = file('/dev/null', 'r')
  so = file('/dev/null', 'a+')
  
  out = sys.stdout
  out.write("Starting: " + cmd + "\n")
  out.flush()
  
  pid = os.fork()
  
  if pid > 0:
    sys.exit(0)
  
  try:
    os.setsid()
  
    # redirect IO
    os.dup2(si.fileno(), sys.stdin.fileno())
    os.dup2(so.fileno(), sys.stdout.fileno())
    os.dup2(so.fileno(), sys.stderr.fileno())

    #Perhaps change to http://antonym.org/node/100 ? - JGR
    os.setgid(grp.getgrnam(QUARRYGROUP)[2])
    os.setuid(pwd.getpwnam(QUARRYUSER)[2])

    proc = popen2.Popen3(cmd)
    
    pf = file(pidfile, "w")
    pf.write(str(proc.pid))
    pf.close()
    
  except: 
    out.write("    [FAILURE]\n")
    e,v,t = sys.exc_info()
    raise e,v,t
    
  return proc 
  
def stop(cmd, pidfile):
  sys.stdout.write("Stopping: " + cmd)
  if os.path.exists(pidfile):
    pf = file(pidfile, "r")
    pid = int(pf.read())
    
    sys.stdout.write(" (%s)" % (pid,))
    
    pf.close()
    try:
      os.kill(pid, signal.SIGKILL)
      sys.stdout.write("    [SUCCESS]\n")
    except OSError:
      print "Warning: %s exists, but process %s not running." % (pidfile,pid)
    except:
      sys.stdout.write("    [FAILURE]")
      e,v,t = sys.exc_info()
      raise e,v,t
    os.remove(pidfile)
  else:
    sys.stdout.write("    [FAILURE]\n")
    print "pidfile ('%s') not found." % (pidfile,)

def usage():
  print "Usage:"
  print "quarryWebService.py {start|stop|restart}"
  

if __name__ == '__main__':
  cmds = [QUARRYSERVE]
  pidfiles = [QUARRYPIDFILE]
  if len(sys.argv) < 2:
    for c, pf in zip(cmds, pidfiles):
      restart(c, pf)
  else:
    cmd = sys.argv[1]
    if   cmd == 'stop':
      for c, pf in zip(cmds, pidfiles):
        stop(c, pf)
    elif cmd == 'start':
      for c, pf in zip(cmds, pidfiles):
        start(c, pf)
    elif cmd == 'restart':
      for c, pf in zip(cmds, pidfiles):
        restart(c, pf)
    else:
      usage()
      

