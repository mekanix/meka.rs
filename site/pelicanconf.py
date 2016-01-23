#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'meka'
SITENAME = u"Meka"
SITEURL = ''

PATH = 'content'

TIMEZONE = 'Europe/Belgrade'

DEFAULT_LANG = u'en'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = 'feeds/atom.xml'
CATEGORY_FEED_ATOM = 'feeds/categories/%s/atom.xml'
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None
TAG_FEED_ATOM = 'feeds/tags/%s/atom.xml'

# Blogroll
LINKS = (('Pelican', 'http://getpelican.com/'),
         ('Python.org', 'http://python.org/'),
         ('Jinja2', 'http://jinja.pocoo.org/'),
         ('You can modify those links in your config file', '#'),)

# Social widget
SOCIAL = (('twitter', 'https://twitter.com/meka_floss'),
          ('upwork', 'https://upwork.com/'),)

DEFAULT_PAGINATION = 10

# Uncomment following line if you want document-relative URLs when developing
# RELATIVE_URLS = True

THEME = 'clean-blog'
DELETE_OUTPUT_DIRECTORY = True
INDEX_SAVE_AS = 'blog/index.html'
MENUITEMS = (
    ('blog', '/blog'),
)
DELETE_OUTPUT_DIRECTORY = True
DISQUS_SITENAME = "meka.rs"
GITHUB_URL = "https://github.com/mekanix"
TWITTER_URL = "https://twitter.com/meka_floss"
