#!/usr/bin/python
from jinja2 import Environment, PackageLoader, meta
env = Environment(loader=PackageLoader('template'))
template_source = env.loader.get_source(env, 'template.tf')
parsed_content = env.parse(template_source)
meta.find_undeclared_variables(parsed_content)