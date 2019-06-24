#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'meka'
SITENAME = u'meka'
SITESUBTITLE = u'Goran Mekic - hacker and a musician'
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

# Social widget
SOCIAL = (
    ('github', 'https://github.com/mekanix'),
    ('twitter', 'https://twitter.com/meka_floss'),
    ('linkedin', 'https://www.linkedin.com/in/goran-mekić-b1030120/'),
    ('envelope', 'mailto:meka@tilda.center'),
    ('rss', '/{}'.format(FEED_ALL_ATOM)),
)

DEFAULT_PAGINATION = 10

# Uncomment following line if you want document-relative URLs when developing
# RELATIVE_URLS = True

THEME = 'theme'
DELETE_OUTPUT_DIRECTORY = True
INDEX_SAVE_AS = 'blog/index.html'
DELETE_OUTPUT_DIRECTORY = True
DISQUS_SITENAME = "mekars"
MATOMO_URL = "matomo.tilda.center"
GITHUB_URL = "https://github.com/mekanix"
TWITTER_URL = "https://twitter.com/meka_floss"
ARTICLE_URL = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/'
ARTICLE_SAVE_AS = 'blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html'
MENUITEMS = (
    ('blog', '/blog'),
    ('resume', '/pages/resume.html'),
    ('videos', '/pages/videos.html'),
)
STATIC_PATHS = [
    'extra/favicon.ico',
    'images',
]
EXTRA_PATH_METADATA = {
    'extra/favicon.ico': {
        'path': 'favicon.ico'
    },
}
PROFILE_IMAGE = "avatar.png"
BIO = "I am Goran Mekić, and I'm Flask/React developer and HardenedBSD user, enthusiast, musician and hacker"
