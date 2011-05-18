#!/usr/bin/env python

import os
import commands
import re
from string import Template

class Module:
  def __init__(self, name):
    print '--------------- Name: %s -------------' % name
    self.name = name
    self.requires = []
    self.exports = {}
    self.variables = {}
    self.default_paths = ['/usr/local/lib/pkgconfig', '/usr/lib/pkgconfig']
    self.pkg_config_path = os.environ['PKG_CONFIG_PATH'].split(':')
    self.file = None
    self.export_regex = re.compile('([A-Z][^=:]*):\s*(.*)')
    self.var_regex = re.compile('([A-Z][^=]*)=\s*(.*)')
    self.operators = ['>', '>=', '<>', '<', '<=', '=']

    multi_arch_host = commands.getoutput('dpkg-architecture -qDEB_HOST_MULTIARCH')
    pkg_multi_arch_path = '/usr/lib/%s/pkgconfig' % multi_arch_host


    if pkg_multi_arch_path not in self.pkg_config_path:
      self.pkg_config_path.append(pkg_multi_arch_path)


    for p in self.default_paths:
      if p not in self.pkg_config_path:
        self.pkg_config_path.append(p)

    for p in self.pkg_config_path:

      if not p:
        continue

      f = os.path.join(p, '%s.pc' % self.name)
      if os.path.exists(f):
        self.file = f
        break

    if self.file is not None:
      print 'Paring: %s' % self.file
      self.parse_file()


      if 'Requires' in self.exports:
        for r in re.split('[, ]', self.exports['Requires']):
          if not r:
            continue
          self.requires.append(r)

      requires_private = []
      current_module = ''
      if 'Requires.private' in self.exports:
        for r in re.split('[, ]', self.exports['Requires.private']):
          if not r:
            continue
          elif r not in self.operators:
            current_module = r
          requires_private.append(r)

      for r in requires_private:
        print r

      for r in self.requires:
        m = Module(r)
        m.dump()

  def dump(self):
    for v in self.exports.keys():
      print '(%s, %s)' % (v, self.exports[v])

  def exists(self):
    pass

  def mod_version (self):
    pass

  def _do_substitution(self, val):
    val = val.strip()
    if '$' in val:
      val = Template(val).safe_substitute(self.variables)

    return val

  def parse_file(self):
    lines = open(self.file).readlines()

    for line in lines:
      line = line.strip()

      if not line:
        continue

      elif ':' in line:
        m = self.export_regex.match(line)
        if m is not None:
          name = m.group(1).strip()
          val = self._do_substitution(m.group(2))
          self.exports[name] = val

      elif '=' in line:
        name, val = line.split('=')
        self.variables[name] = self._do_substitution(val)

if __name__ == '__main__':
  m = Module('cairo')
  m.dump()
