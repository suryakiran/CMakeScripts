import django
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
    
emacs_template_file = yml['file']['in']['emacs']
    
settings.configure (
    TEMPLATE_DIRS = [os.path.dirname(emacs_template_file)]
    )
django.setup()

f = open(yml['file']['out']['emacs'], 'w')
f.write(loader.render_to_string(os.path.basename(emacs_template_file), yml))
f.close()
