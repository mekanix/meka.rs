#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = "meka"
SITENAME = "meka"
SITESUBTITLE = "Goran Mekic - hacker and a musician"
SITEURL = ""

PATH = "content"

TIMEZONE = "Europe/Belgrade"

DEFAULT_LANG = "en"

# Feed generation is usually not desired when developing
FEED_ATOM = "feeds/atom.xml"
FEED_ATOM_URL = "/feeds/atom.xml"
CATEGORY_FEED_ATOM = "feeds/categories/{slug}/atom.xml"
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None
TAG_FEED_ATOM = "feeds/tags/{slug}/atom.xml"

# Social widget
SOCIAL = (
    ("github", "brands", "https://github.com/mekanix"),
    ("mastodon", "brands", "https://bsd.network/@meka"),
    ("linkedin", "brands", "https://www.linkedin.com/in/goran-mekić-b1030120/"),
    ("envelope", "", "mailto:meka@tilda.center"),
    ("rss", "", "/{}".format(FEED_ATOM)),
)

DEFAULT_PAGINATION = 10

# Uncomment following line if you want document-relative URLs when developing
# RELATIVE_URLS = True

THEME = "theme"
DELETE_OUTPUT_DIRECTORY = True
INDEX_SAVE_AS = "blog/index.html"
DISQUS_SITENAME = "mekars"
#  MATOMO_URL = "matomo.tilda.center"
GITHUB_URL = "https://github.com/mekanix"
TWITTER_URL = "https://twitter.com/meka_floss"
ARTICLE_URL = "blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/"
ARTICLE_SAVE_AS = "blog/{date:%Y}/{date:%m}/{date:%d}/{slug}/index.html"
MENUITEMS = (
    ("blog", "/blog"),
    ("resume", "/pages/resume.html"),
    ("videos", "/pages/videos.html"),
)
STATIC_PATHS = [
    "extra/favicon.ico",
    "images",
]
EXTRA_PATH_METADATA = {
    "extra/favicon.ico": {"path": "favicon.ico"},
}
PROFILE_IMAGE = "avatar.png"
BIO = "I am Goran Mekić, and I'm Flask/React developer and FreeBSD user, enthusiast, musician and hacker"

MARKDOWN = {
    "extension_configs": {
        "markdown.extensions.toc": {"title": "Table of contents:"},
        "markdown.extensions.codehilite": {"css_class": "highlight"},
        "markdown.extensions.extra": {},
        "markdown.extensions.meta": {},
    },
    "output_format": "html5",
}
