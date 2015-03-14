#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
import re
import urllib2

PAGES = [
  'http://www.iba-world.com/index.php?option=com_content&id=89&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=186&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=187&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=188&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=189&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=190&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=191&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=192&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=193&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=194&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=195&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=196&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=197&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=198&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=199&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=200&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=201&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=202&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=203&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=204&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=205&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=206&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=207&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=208&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=262&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=209&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=210&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=211&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=212&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=213&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=214&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=215&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=216&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=260&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=217&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=265&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=218&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=269&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=266&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=268&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=219&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=220&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=221&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=263&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=222&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=223&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=224&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=225&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=226&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=227&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=259&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=228&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=229&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=230&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=231&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=232&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=233&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=234&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=235&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=236&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=237&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=238&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=239&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=261&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=240&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=241&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=242&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=243&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=244&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=245&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=246&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=247&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=248&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=249&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=250&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=251&tmpl=component&task=preview',
  'http://www.iba-world.com/index.php?option=com_content&id=252&tmpl=component&task=preview'
]

results = {}

for url in PAGES:
  page = urllib2.urlopen(url)
  text = page.read()

  match = re.search(r'class="info1".+?>(.+?)<.*?<ul class="list">(.+?)</ul>(.*?)</', text, re.DOTALL)

  if not match:
    print 'failure: ' + url
    continue

  title = match.group(1).title()

  cl2oz = {
    "1": "1/3",
    "2": "2/3",
    "3": "1",
    "4": "1 1/3",
    "5": "1 2/3",
    "6": "2",
    "9": "3",
    "12": "4",

    "4.5": "1 1/2",
    "1.5": "1/2",
    "0.75": "1/4"
  }

  def ingredient2str(ingredient):
    ingredient = ingredient.strip().replace('<li>', '').replace('</li>', '').replace('\xc2\xa0', ' ')
    if not ingredient:
      return None

    match = re.search(r'(\d+(\.\d+)?)\s(.*?)\s(.*)', ingredient)
    if match:
      name = match.group(4).lower().strip()
      amt = match.group(1).strip()
      unit = match.group(3).strip()
      if unit == 'cl' and cl2oz.get(amt, None):
        amt = cl2oz[amt]
        unit = 'oz'

      return '''
      -
        tag: "%s"
        displayAmount: "%s"
        displayUnit: "%s"
        displayIngredient: "%s"''' % (name, amt, unit, name)
    else:
      return '''
      -
        tag: "%s"
        displayIngredient: "%s"''' % (ingredient.lower(), ingredient.lower())

  ingredients = filter(bool, map(ingredient2str, match.group(2).split('\n')))

  def desc2str(desc):
    return re.sub(r'<.*?>', '', desc).replace('\xc2\xa0', ' ').strip()

  desc = filter(bool, map(desc2str, re.sub(r'<\s*?br\s*?/?>', '\n', match.group(3)).split('\n')))
  if len(desc) == 1:
    desc = '"%s"' % desc[0]
  else:
    desc = '|\n      ' + '\n      '.join(desc)

  results[title] = '\n'.join(map(lambda l: '  ' + l, ('''-
    name: "%s"
    ingredients: %s
    instructions: %s
    source: "IBA"
    url: "http://www.iba-world.com/index.php?option=com_content&view=article&id=88"''' % (title, ''.join(ingredients), desc)).split('\n')))

for key in sorted(results):
  print results[key]
