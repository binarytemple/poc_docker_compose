# Limitations

When adding a new worker node to the cluster it is necessary to execute `docker-compose restart` in order for the new host to be 
added to the hosts files on the existing nodes.. implying a restart of the entire cluster.

The docker-compose.yml specified the following cluster topology:

```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                   NAMES
01dac4baf76b        tutum/haproxy       "python /haproxy/main"   25 minutes ago      Up 10 minutes       443/tcp, 1936/tcp, 0.0.0.0:80->80/tcp   1_lb_1
21da13288b94        web:latest          "/bin/sh -c 'python /"   25 minutes ago      Up 10 minutes       80/tcp                                  1_web_2
8470a012f943        web:latest          "/bin/sh -c 'python /"   26 minutes ago      Up 10 minutes       80/tcp                                  1_web_3
2e93f23dd421        web:latest          "/bin/sh -c 'python /"   26 minutes ago      Up 10 minutes       80/tcp                                  1_web_4
2c4a4493f8f4        redis               "/entrypoint.sh redis"   34 minutes ago      Up 10 minutes       6379/tcp                                1_redis_1
b147be2ddcff        swarm:latest        "/swarm join --advert"   11 days ago         Up 6 hours                                                  swarm-agent
3ee170a02993        swarm:latest        "/swarm manage --tlsv"   11 days ago         Up 6 hours                                                  swarm-agent-master
```

I then added a new web worker node using the following command:

```
docker-compose scale web=4
```

I executed `docker-compose restart` and restarted the cluster, this is what the hosts file looked like on `1_lb_1` (the haproxy load balancer)
after the restart operation completed:

```
root@01dac4baf76b:/# cat /etc/hosts 
172.17.0.6      01dac4baf76b
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
172.17.0.3      1_web_2 21da13288b94
172.17.0.4      1_web_3 8470a012f943
172.17.0.5      1_web_4 2e93f23dd421
172.17.0.3      web 2 1da13288b94 1_web_2
172.17.0.3      web_2 21da13288b94 1_web_2
172.17.0.4      web_3 8470a012f943 1_web_3
172.17.0.5      web_4 2e93f23dd421 1_web_4
```

I then carry out a couple more operations, asking docker-compose to set the number of 'web' instances to 4.

This is what the hosts file on '1\lb\_1' quickly looks like:

```
root@01dac4baf76b:/# cat /etc/hosts 
172.17.0.6      01dac4baf76b
127.0.0.1       localhost
::1     localhost ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
172.17.0.5      1_web_4 2e93f23dd421
172.17.0.3      web 21da13288b94 1_web_2
172.17.0.3      web_2 21da13288b94 1_web_2
172.17.0.4      web_3 8470a012f943 1_web_3
172.17.0.5      web_4 2e93f23dd421 1_web_4
172.17.0.3      1_web_2 21da13288b94
172.17.0.4      1_web_3 8470a012f943
```

But when I run a `docker ps` I see 5 instances of 'web' are now running...

```
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                   NAMES
bb9d09b78eb3        web:latest          "/bin/sh -c 'python /"   3 minutes ago       Up 3 minutes        80/tcp                                  1_web_4
7e6c2572892e        web:latest          "/bin/sh -c 'python /"   3 minutes ago       Up 3 minutes        80/tcp                                  1_web_3
303177753d80        web:latest          "/bin/sh -c 'python /"   3 minutes ago       Up 3 minutes        80/tcp                                  1_web_2
d46f52da6421        web:latest          "/bin/sh -c 'python /"   4 minutes ago       Up 4 minutes        80/tcp                                  1_web_5
c2f110b3d1d6        web:latest          "/bin/sh -c 'python /"   4 minutes ago       Up 4 minutes        80/tcp                                  1_web_6
```

I had specified `docker-compose scale web=5`. Lets check the '/etc/hosts' file on '1_lb_1' again.

```
docker exec -i -t 1_lb_1 /bin/bash -c 'cat /etc/hosts'
```

```
172.17.0.6	8172a2977efc
127.0.0.1	localhost
::1	localhost ip6-localhost ip6-loopback
fe00::0	ip6-localnet
ff00::0	ip6-mcastprefix
ff02::1	ip6-allnodes
ff02::2	ip6-allrouters
172.17.0.5	1_web_4 bb9d09b78eb3
172.17.0.7	1_web_5 d46f52da6421
172.17.0.3	web_2 303177753d80 1_web_2
172.17.0.4	web_3 7e6c2572892e 1_web_3
172.17.0.8	web_6 c2f110b3d1d6 1_web_6
172.17.0.3	1_web_2 303177753d80
172.17.0.4	1_web_3 7e6c2572892e
172.17.0.5	web_4 bb9d09b78eb3 1_web_4
172.17.0.7	web_5 d46f52da6421 1_web_5
172.17.0.8	1_web_6 c2f110b3d1d6
172.17.0.3	web 303177753d80 1_web_2
```

That seems ok. But needing to restart the instance is a minor bother. 


# With docker swarm

With a docker swarm already created, `docker-compose` will operate transparently upon swarm components provided
you have created the environment appropriately.

To expose the swarm environmental variables you will need to execute the following:

```
eval $(docker-machine env swarm-master --swarm)
```

After doing so we can observe from the `docker ps` that the instances are running within the docker swarm:

```
CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS   NAMES
a4f253b8e9b9        packetops/web:latest   "/bin/sh -c 'python /"   37 minutes ago      Up 5 minutes        80/tcp  swarm-master/1_web_5
c07271f3fa82        packetops/web:latest   "/bin/sh -c 'python /"   37 minutes ago      Up 4 minutes        80/tcp  swarm-master/1_web_4
3300a5fc1ae8        packetops/web:latest   "/bin/sh -c 'python /"   37 minutes ago      Up 4 minutes        80/tcp  swarm-master/1_web_3
7ccd55b3678e        packetops/web:latest   "/bin/sh -c 'python /"   3 hours ago         Up 4 minutes        80/tcp  swarm-master/1_web_2

```

Continued on [StackOverflow](http://stackoverflow.com/questions/35002493/docker-swarm-and-docker-compose-how-to-dynamically-add-nodes-and-have-them-resol)


