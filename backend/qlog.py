
# setup logging
import logging
import traceback

#setup log file location
import config
logfile = config.app_path + "/quarry.log"
import logging.handlers as handlers

def debug(msg):
  syslogger.debug(msg)
def info(msg):
  syslogger.info(msg)
def critical(msg):
  syslogger.critical(msg)
def error(msg):
  syslogger.error(msg)



def ExceptionMessage(e,v,t):
  error("Exception: %s" % ("".join(traceback.format_exception(e,v,t)),))

syslogger = logging.getLogger('quarry')
filelog = handlers.RotatingFileHandler(logfile, maxBytes=1024*1024*5, backupCount=10)
frmttr = logging.Formatter('%(asctime)s %(levelname)s %(message)s')
filelog.setFormatter(frmttr)
syslogger.addHandler(filelog)

console = logging.StreamHandler()
console.setLevel(logging.INFO)
formatter = logging.Formatter('%(asctime)s: %(message)s')
console.setFormatter(formatter)
syslogger.addHandler(console)

syslogger.setLevel(logging.DEBUG)

def DebugOn(level=logging.DEBUG):
  SetLogLevel(level)

def DebugOff():
  SetLogLevel(logging.INFO)

def SetLogLevel(level):
  syslogger.setLevel(level)
  filelog.setLevel(level)
  console.setLevel(level)

