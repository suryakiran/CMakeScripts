import os, sys
import argparse
import yaml
from django.template import loader
from django.conf import settings

parser = argparse.ArgumentParser (prog = 'write-package-library-details')
parser.add_argument ('-o', dest = 'output', required = True)
parser.add_argument ('-p', dest = 'prefix', required = True)
parser.add_argument ('-i', dest = 'input', required = True)
parser.add_argument ('-y', dest = 'yml_file', required = True)

args = parser.parse_args()
d = {}
d['lib'] = {}
d['lib']['prefix'] = args.prefix
d['lib']['name'] = '%s_LIBRARIES' % (args.prefix)

d['lib']['debug'] = {}
d['lib']['debug']['name'] = '%s_DEBUG_LIBRARY' % (args.prefix)
d['lib']['debug']['value'] = '${%s}' % (d['lib']['debug']['name'])

d['lib']['release'] = {}
d['lib']['release']['name'] = '%s_OPTIMIZED_LIBRARY' % (args.prefix)
d['lib']['release']['value'] = '${%s}' % (d['lib']['release']['name'])

yml = yaml.load(open(args.yml_file, 'r'))

settings.configure (
    TEMPLATE_DIRS = [yml['cmake']['configure_dir']]
    )

f = open(args.output, 'w')
f.write(loader.render_to_string(args.input, d))
f.close()
