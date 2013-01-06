from django.template import loader
from django.conf import settings
import yaml, os
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('-y', dest = 'yaml_input_files', default = None, required = True, action = 'append')
parser.add_argument('-d', dest = 'editor_search_dirs', default = None, required = False, action = 'append')
args = parser.parse_args()
yml = {}

for f in args.yaml_input_files:
    yml.update(yaml.load(open(f, 'r')))

yml['editor_search_dirs'] = args.editor_search_dirs
yml['os'] = os

template_files = {
    yml['file']['in']['emacs']: yml['file']['out']['emacs'],
    yml['file']['in']['gvim']: yml['file']['out']['gvim']
                }
    
settings.configure (
    TEMPLATE_DIRS = [yml['cmake']['configure_dir']]
    )

for tf in template_files:
    f = open(template_files[tf], 'w')
    f.write(loader.render_to_string(tf, yml))
    f.close()
