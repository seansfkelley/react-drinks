import requests
import urllib
import json
import pickle
import re


def make_url(value):
  formatted_value = value.lower().replace(' ', '+').replace('&', '%26')
  return 'http://kindredcocktails.com/cocktail/ingredient/autocomplete/hierarchy?parent=%s&term=%s&usage=search' % (formatted_value, formatted_value)

class Node:
  def __init__(self, **kwargs):
    self.value = kwargs['value']
    self.label = kwargs['label']
    self.type = kwargs['type']
    self.children = []

    assert (self.value is not None) and (self.label is not None) and (self.type is not None)

  def __repr__(self):
    return self.label.encode('utf-8')

  # def __repr__(self):
  #   s = '> ' + self.value
  #   if self.children:
  #     for c in self.children:
  #       s += '\n' + '\n'.join('  ' + l for l in unicode(c).split('\n'))
  #   return s

def fetch(node):
  global i
  i += 1

  already_have[node.value] = node

  url = make_url(node.value)
  response = requests.get(url).text
  objects = json.loads(response)

  for r in objects:
    if r['value'] and r['label'] and u'hierarchy' not in r and r['value'] != node.value:
      child = Node(**r)
      if child.value in already_have:
        print ('%6i have' % i), child.value
        node.children.append(already_have[child.value])
      else:
        node.children.append(child)
        print ('%6i get ' % i), child.value
        fetch(child)

i = 0

already_have = {}

# root = Node(value=u'', label=u'', type=3)
# fetch(root)

# with open('scraper-output', 'w') as f:
#   pickle.dump(root, f)

edges = set()

def output(node):
  if node in already_have:
    return

  already_have[node] = True

  for c in node.children:
    edges.add((node, c))
    output(c)

def fmt(value):
  if value == '':
    return '__root__'
  else:
    return re.sub('^([0-9])', r'_\1', re.sub('[^a-zA-Z0-9 _]', '', value.encode('ascii', 'ignore').replace(' ', '_')))


with open('scraper-output', 'r') as f:
  root = pickle.load(f)

  output(root)

  print 'digraph g {'

  for (source, target) in edges:
    print fmt(source.value), '->', fmt(target.value), ';'

  print '}'
