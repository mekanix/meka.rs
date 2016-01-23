Title: Cloud Computing Basics 5
Date: 2014-11-17 22:00
Slug: blog/cloud-computing-basics-5


You hear me talk about thousands of servers and never about how to get to the
point where you make 10,000 servers go up. The fancy word is "provisioning". I
don't even know what's it supposed to mean, but for me it means "make a recipe
which will make machine configured for a purpose". As we're talking about cloud
computing and Docker, what we need is a machine that is Consul and Registrator
ready. Getting to that point on multiple servers is not such a short task, but
it's repetitive. And, along comes [Ansible](http://www.ansible.com/home). Over
the years people realized that they want a language for specifying server
configuration that is declarative, so Ansible uses [YAML](http://www.yaml.org/)
for that. We also need a language to describe the configuration of different
services, and[Jinja2](http://jinja.pocoo.org/docs/dev/) offers that. On top of
that, it's Python, so it has extra plus on my scale. As you can't just apply
something on your servers and hope for the best, you need some development
environment. I think [Vagrant](https://www.vagrantup.com/) has no competition
in that field, yet. Let's see on the example of this blog how to use it. Clone
[meka.rs](https://github.com/mekanix/meka.rs), and execute `vagrant up`. It
should download CentOS 7 box, create new virtual machine in VirtualBox and
provision it with Ansible. What it does is not that important right now. Let's
start with example Ansible task:

    - name: install docker
      sudo: yes
      yum:
          pkg: docker
          state: latest

Yeah, it's that simple and readable. That's fine, but let's dive into the
details. First, there's a
[site.yml](https://github.com/mekanix/meka.rs/blob/master/provision/site.yml)
file. You can see the title of Ansible playbook, hosts on which it will be run
on and roles it will apply. As I have [two roles](https://github.com/mekanix/meka.rs/tree/master/provision/roles)
but mention only one in site.yml, it means that role `common` is a dependency
of `meka`. That dependency is noted in
[meta](https://github.com/mekanix/meka.rs/blob/master/provision/roles/meka/meta/main.yml).
There's only one thing missing: list of servers that this playbook applies to.
Vagrant will generate that list on the fly depending on the configuration inside
Vagrantfile, like number of machines. Nice thing about Vagrant is that it will
share directory of the repo as `/vagrant` inside virtual machine. Basically this
means that you can code on your laptop/desktop with your favorite editor and see
those changes on the same distribution that is used in production, on the same
docker that is used in production. Idea is to have almost identical environment
in all stages, like development, testing, pre-production, production, ... It
enables developers to make less bugs that are caused by differences in
environments.

Ansible is such an important and easy to use tool, that I have no more words to
describe it but "read all from the
[provision directory](https://github.com/mekanix/meka.rs/tree/master/provision)".
It's simple and powerful.

[previous](/blog/2014/11/16/cloud-computing-basics-4)
[next](/blog/2014/11/20/cloud-computing-basics-6)
