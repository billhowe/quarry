#!/usr/local/bin/python2.3

import re, os, sys, string, perl, operator, time
import os.path
import qlog
import config, bulkloader

# global configuration
rulefile = config.app_path + 'rule'
perloutputfile = '/tmp/perloutput.tmp'
perloutput = file(perloutputfile, 'w+')
pythonoutputfile = '/tmp/pythonoutput.tmp'
pythonoutput = file(pythonoutputfile, 'w+')

scriptdir = config.app_path + 'collectors/'

badchars = set([';','.',')','(','[',']','|','/',':','{','}'])

patt = '''[;.,()|/:{}[\]]'''
charpatt = re.compile(patt)

def clean(s):
  return charpatt.sub('_', s)

def clean(s):
  for b in badchars:
    s = s.replace(b, '_')
  return s

class Script:
    '''arbitrary comand line script of the form <command> <filename>
       script is expected to call an AddItem for each desciption item
      it wants to record.'''
      
    scriptfilename = ''
    
    def __init__(self, scriptfilename):
        self.scriptfilename = scriptfilename

    def clean(self, line):
        a = string.rstrip(line)
        b = string.strip(a,';')
        c = string.split(b, ';')
        return c
    
    def cleanlines(self, lines):
      ds = [self.clean(l) for l in lines]
      return [d for d in ds if len(d) == 4]

    def execute(self,target):
        ''' returns the raw output of the script.  Should be a ';' delimited string'''
	cmd = scriptdir + self.scriptfilename + " " + target 
	script_in,script_out = os.popen2(cmd)
	return script_out.read()

    def handlenulls(self, descriptor):
        pass

    def __repr__(self):
      return self.scriptfilename

class PythonScript(Script):
    '''specialized for python.  Use execfile to
       execute the sucker in the same namespace.
       We have to munge sys.argv, which is hack-tacular.
      all in the name of avoiding any constraint on the script
      other than 'must work from the command line.' and still
      maintaining efficiency '''

    def __init__(self, scriptfilename):
      self.scriptfilename = scriptdir + scriptfilename
      self.spoofArgv = [scriptfilename,'<target>']
      self.scriptfile = file(scriptdir + scriptfilename)
      self.scriptcode = self.scriptfile.read()
      sys.path.append(scriptdir)

    def execute(self, target):
      originalArgv = sys.argv
      self.spoofArgv[1] = target
      sys.argv = self.spoofArgv
      
      execfile(self.scriptfilename)
      
      sys.argv = originalArgv
      ss = pythonoutput.read() 
      return ss

class PerlScript(Script):
    '''wicked hackery to allow scripts written
       as a command line program to be wrapped as a 
       function for efficient repeated calling'''
    def __init__(self, scriptfilename):
        self.scriptfilename = scriptfilename
        self.cleanname = clean(scriptfilename)
      	scriptfile = file(scriptdir + scriptfilename,'r')
        code = scriptfile.readlines()
        header = ['package %s;' % self.cleanname, \
                  'sub %s {\n' % self.cleanname, \
                  '@ARGV = @_;\n']
        footer = ['\n}', '1;']
        wrappedAsFunction = header + code + footer
        self.scriptcode = '\n'.join(wrappedAsFunction)
        inc = perl.get_ref("@INC")
        inc.append(scriptdir)
        perl.eval(self.scriptcode)
        scriptfile.close()

    def execute(self, target):  
        #print self.scriptcode
        #print '%s::%s' % (self.cleanname, self.cleanname), target
	perl.call('%s::%s' % (self.cleanname, self.cleanname), target)
        #ds = perl.get_ref("@%s::descriptors" % (self.cleanname,))
        p = perloutput
        results = p.read()
        #results = "\n".join([";".join(d) + ";" for d in ds])
	return results

class Rule:
    ''' a rule is the association of a regular expression with 
        a script file name, and an indication of the language used.  
        (Certain languages can be optimized; python and perl for instance 
        can be executed in the local interpreter instead of requiring a 
        separate unix process.'''
    def __init__(self, ruletext):
    
        try:
          components = ruletext.split()
          regexp = components[0]
	  scripts = components[1:]
	  self.scripts = [self.mkScript(s) for s in scripts]
          #[regexp, scriptfilename, interpreter] = ruletext.split()
        except ValueError:
          raise ValueError("Bad Rule in rule file: " + ruletext)
        self.regexptext = regexp
        self.regexp = re.compile(regexp)

    def mkScript(self, scriptfilename):
      if os.path.exists(scriptdir + scriptfilename):
        f = file(scriptdir + scriptfilename)
        shbang = f.readline()
      else:
        raise TypeError("Bad script filename in rule file. '%s' does not appear to exist via os.path.exists" % (scriptdir + scriptfilename,))

      interpreter = shbang[2:]
      if 'perl' in interpreter:
         return PerlScript(scriptfilename)
      elif 'python' in interpreter:
         return PythonScript(scriptfilename)
      else:
           return Script(scriptfilename)
      

    def __repr__(self):
      return "'%s' -> %s" % (self.regexptext, self.scripts)

    def activate(self, target):
        '''test this rule against a target, executing the script 
           on a match.'''
        qlog.debug("Testing Rule '%s' against '%s'" % (self, target))
        if self.regexp.match(target):
          qlog.debug('Match')
          try:
	    return reduce(operator.concat, [s.execute(target) for s in self.scripts])
            #return self.script.execute(target)
          except:
            (e, v, t) = sys.exc_info()
            qlog.error(str(e) + ": " + str(v))
            raise e, v,t
            return '' 
        else:
            return ''

class Harvester:
    '''manager for rules and scripts.  
       harvests metadata given a rule file and a target file name'''
    def __init__(self):
        f = file(rulefile)
        cleanrules = [x.strip() for x in f.readlines()]
        self.rules = [Rule(x) for x in cleanrules 
                              if len(x) > 0 and x[0] not in '#/-']
  
    def harvest(self, target):
        msg = "Each metadata item should have 4 tokens; something's wrong: %s, %s"
        distincts = {}

        for r in self.rules:
          ans = string.strip(r.activate(target))

          if len(ans) > 0:
            tokens = ans.split(';')[:-1]
            n = len(tokens)

            if n%4 !=0: raise ValueError, msg % (n, tokens)

            d = [(string.strip(tokens[i]).lower(), 
                   (tokens[i+1], tokens[i+2], tokens[i+3])
                 ) for i in range(0,n,4)]
            distincts.update(d)
#              distincts[string.strip(tokens[i])] = (tokens[i+1], tokens[i+2], tokens[i+3])
        retval = [(n, v, d, t) for (n, (v,d,t)) in distincts.iteritems()]
        return retval

    def harvestDir(self, rundir, loader=bulkloader.BulkLoader()):
      qlog.info("Harvesting %s" % (rundir,))
      t = time.time()
      
      if not os.path.exists(rundir):
        print "%s does not exist." %(rundir,)
        qlog.error("run %s does not exist. (broken link?)")
        return
      for root, dirs, files in os.walk(rundir):
        for fname in files:
          fullpath = "%s/%s" % (root, fname)
          try:
            ds = self.harvest(fullpath)
          except:
            (e, v, t) = sys.exc_info()
            print "Error processing %s/%s: %s: %s, %s" % (root, fname, e,v,t)
            sys.exit(1)
            return
          if ds: 
            loader.addresource(fullpath)
            for d in ds: loader.adddescriptor(d)
          
      qlog.info("...harvested in %s seconds." % (time.time() - t,))

def main(args):
  if len(args) < 2:
    print "Usage: python harvest.py <directory to harvest>"
    sys.exit()

  h = Harvester()
  dir = args[1]

  t = time.time()
  b = bulkloader.BulkLoader()
  b.truncateFiles()
  #import profile
  #profile.runctx("h.harvestDir(dir, b)", globals(), locals())
  h.harvestDir(dir, b)
  b.closeFiles()

  print "Harvested %s in %s seconds" % (dir,time.time() - t)

  if len(args) < 3: return

  safename = '_'.join(dir.split('/'))
  
  datadir =config.datadir + safename
  copytmpfiles = "cp %s/*.tmp %s" % (config.tmpdir, datadir)
  os.mkdir(datadir)
  os.system(copytmpfiles)

if __name__ == '__main__':
  main(sys.argv)
