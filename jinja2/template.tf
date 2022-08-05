module {{name}} {
    source = ""
    exclusions = "{{exclusions['Python'][scope]}}"
}
# EXLUSIONS
{{exclusions}}


# ##############
{% for key in exclusions %}
{{key}}
{% endfor %}

# GET THE SCOPE
{% for key in exclusions['python'] %}
{{key}}
{% endfor %}

# works
{% for dict_item in exclusions['Python'] %}
{{ dict_item['scope']}}
{% endfor %}

# join
{% for dict_item in exclusions['Python'] %}
{{ dict_item['scope']|join(',')}}
{% endfor %}

##########
{% for dict_item in exclusions['Python'] %}
{{ (dict_item['scope']|string)|join(',')}}
{% endfor %}


##########
{% set mylist = []%}
{% for dict_item in exclusions['Python'] %}
{{ mylist.append(dict_item['scope']) }}
{% endfor %}

{{ mylist|join('","')}}


