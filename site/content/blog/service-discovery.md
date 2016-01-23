Title: Service Discovery
Date: 2014-11-09 22:00
Slug: blog/service-discovery


Yes, docker is my new favorite toy, and it is big word on the Internet. So I have my hands in the gutter trying to figure out the optimal way to configure my cloud. What's the big deal? For start, etcd is not my best friend, any more. I like Consul implementation and features much more. Hence, CoreOS is not the perfect distribution. I'm using Debian Jessie which is in beta2 stage in the time of writing this post. The reson for this switch is Registrator. Consul, Registrator and Consul-Template are 3 projects that make service discovery a piece of cake.

Consul is something like a distributed database. It stores key/value pairs. It sounds like "not much" but it's built on top of Serf, so it's built to be distributed. Consul, also, has built in DNS server, so key/value pairs can be A or SRV records. In one word "where is my postgresql docker container".

Registrator is just crazy. You give it Docker's socket file to listen for events, and every time new docker container is up, it automaticly registares them in Consul, and deregisters them when container is down. This means that every time new application container is up, you can query it via Consul's DNS protocol. If you start your containers with -P, for example, Registrator will register the ports your container is bind to.

Consul-Template is golang program that listens for changes in Consul, generates configuration of a service (say, nginx), and runs a command (say, service nginx restart). Why is this cool? Just imagine you have your load balancer, application server and database server running. You have a peak, and you start one more application server, which needs to be added to load balancer, and configured with database connection. With consul-template, it's as easy as starting new application container. Because Registrator will pick up on which IP and port it is awailable, consul-template on load balancer is able to regenerate configuration and restart nginx. If hosting provider has autoscaling support (I know AWS has it), you have your cloud dynamicly scaling. How cool is that?
