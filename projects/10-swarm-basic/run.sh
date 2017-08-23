
# SWARM is the orchestration engine for docker

# create 3 droplets on digital ocean
# 138.68.246.21 (node1)
# 138.197.192.14 (node2)
# 138.68.57.141 (node3)

# login to all 3 
# ./csshX --login root 138.68.246.21 138.197.192.14 138.68.57.141 

# install docker on all
# curl -fsSL get.docker.com -o get-docker.sh
# sh get-docker.sh

# init swarm with public ip on node1 and make the other 2 join as workers
# on node1: docker swarm init --advertise-addr 138.68.246.21
# on node2: docker swarm join --token SWMTKN-1-2urenei75iyiip23pev9fet2xibnrq8tni72p56dt5g3n27ep2-6pw028w5u9hv2l9gjrey85s4d 138.68.246.21:2377
# on node3: docker swarm join --token SWMTKN-1-2urenei75iyiip23pev9fet2xibnrq8tni72p56dt5g3n27ep2-6pw028w5u9hv2l9gjrey85s4d 138.68.246.21:2377

# make node2 and node3 swarm managers (node1 will be leader since we did swarm init there)
# docker node update --role manager node2
# docker node update --role manager node3

# AT THIS POINT, WE HAVE 3 SERVERS, ALL READY TO SPIN UP CONTAINERS

# create a new service and all that will do is ping
# since we have 3 servers, one container will spin up on all 3 nodes
# docker service create --replicas 3 alpine ping 8.8.8.8

# get running services
# docker service ls

# update replicas from 3 to 6
# now each node will run 2 same containers
# docker service update <sid> --replicas 6

# should show 2 running containers on all 3 nodes
# docker container ls
# docker container rm -f <cid>

# remove the service
# docker service rm <sid>

# no service should be running
# docker service ls

# no containers should be running
# docker container ps