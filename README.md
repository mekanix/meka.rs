meka.rs
========

### Requirements and development setup
- Python (with pip)

### Setup
Inside project dir:

    $ git submodule update --init
    $ pip install -U -r requirements.txt
    $ cd site
    $ ./develop_server.sh start

Point your browser to [the site](http://localhost:8000/)

The static files are inside PROJECT_ROOT/site/output. The best way to put it to
your server is rsync, but I leave that to you.
