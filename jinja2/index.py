#!/usr/bin/python
import jinja2
import json

with open('source.json') as f:
  data = json.load(f)

#with open('gov.json') as f:
#  data2 = json.load(f)

templateLoader = jinja2.FileSystemLoader(searchpath="./")
templateEnv = jinja2.Environment(loader=templateLoader)
TEMPLATE_FILE = "template.tf"
template = templateEnv.get_template(TEMPLATE_FILE)
outputText = template.render(data)  # this is where to put args to the template renderer

print(outputText)
