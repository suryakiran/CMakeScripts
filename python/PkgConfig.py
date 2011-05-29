#!/usr/bin/env python

import os
import commands
import re
from string import Template
from distutils.version import StrictVersion as Version

class Package:
  def __init__(self, name):
    self.name = name
    self.min_version_reqd = None
    self.max_version_reqd = None
    self.parent_package = None
    self.is_private = False

  def set_min_version_reqd(self, min_ver):
    self.min_version_reqd = min_ver

  def set_max_version_reqd(self, max_ver):
    self.max_version_reqd = max_ver

  def set_is_private(self, private):
    self.is_private = private

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
    self.required_packages = []
    self.requires_with_version_regex = re.compile(
                    '([^\s]*)\s*([<>!]=?)\s*((?:\d+\.)?(?:\d+\.)?(?:\d+)?)'
                    )
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
      print 'Parsing: %s' % self.file
      self.parse_file()

      requires = {
          'Requires' : False, 
          'Requires.private' : True
          }

      for r in requires.items():
        req = self.exports.get(r[0])

        if req is None:
          continue

        for mtch in self.requires_with_version_regex.finditer(req):
          p = Package(mtch.group(1))
          p.set_is_private(r[1])
          op = mtch.group(2)
          ver = Version(mtch.group(3))

          if op == '<':
            p.set_max_version_reqd (ver)
          elif op == '<=':
            p.set_max_version_reqd (ver)
          elif op == '>=':
            p.set_min_version_reqd (ver)
          elif op == '>':
            p.set_min_version_reqd (ver)

          self.required_packages.append(p)

        for s in self.requires_with_version_regex.sub('', req).split():
          if not s:
            continue
          else:
            p = Package(s)
            p.set_is_private(r[1])

          self.required_packages.append(p)

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
