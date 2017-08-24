
# SWARM is the orchestration engine for docker

# setup ssh keys in dgitalocean for root access
# https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
# eval `ssh-agent -s`
# ssh-add ~/.ssh/id_rsa_digitalocean

# use csshX to login on all
# ./csshX --ssh_args "-i /Users/vaidesai/.ssh/id_rsa_digitalocean" --login root 138.68.246.21 138.68.57.141 138.197.192.14 

# start 3 replicas of elastic search
# docker service create --name search -p 9200:9200 --replicas 3 elasticsearch:2

# verify service is up
# ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
# z4ut048b2o6j        search              replicated          3/3                 elasticsearch:2     

# make sure all nodes have 1 container up
# docker service ps search
# ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE              ERROR               PORTS
# saw97d2qqvwf        search.1            elasticsearch:2     node2               Running             Preparing 27 seconds ago                       
# msunzjiaab4r        search.2            elasticsearch:2     node3               Running             Running 6 seconds ago                          
# vahr2s5xvcco        search.3            elasticsearch:2     node1               Running             Running 4 seconds ago                          

# check the loadbalancing happening automcatically
# go to node1 and try the following multiple times:
# curl localhost:9200

# you should have seen every node taking the request one at a time even though you are specifically running the curl for a particular host
# this is because swarm by default will create an internal LB on every node which first gets the request
# and then it will roundrobin the request on available nodes
# PLEASE NOTE THAT THIS IS NOT A PUBLIC VIP AND IS ACCESSIBLE ONLY WITHIN THE SWARM CLUSTER

# remove the service
# docker service rm search

# no service should be running
# docker service ls

# no containers should be running
# docker container ps

##### MESH ROUTING #####

# this is what happened internally:
# each node is running one container
# each container is running elasticsearch on port 9200
# each container then exposed 9200 outside on the host since we specified -p 9200:9200
# swarm internally created LB on every node listening on port 9200
# so everytime you hit a node, the request 1st went to swarm LB on that node
# and that LB internally did the load balancing for you

# THIS ALL HAPPENED DUE TO MESH ROUTING
# Routes ingress (incoming) packets for a Service to proper Task
# Spans all nodes in Swarm
# Uses IPVS from Linux Kernel
# Load balances Swarm Services across their Tasks
# Two ways this works:
#   - Container-to-container in a Overlay network (uses VIP)
#   - External traffic incoming to published ports (all nodes listen)

# DOWNSIDES:
# This is stateless load balancing
#   - cannot handle cookies, sessions, etc.
#   - no sickiness for any client to a specific container
# This LB is at OSI Layer 3 (TCP), not Layer 4 (DNS)
#   - cannot run multiple websites on different ports in same swarm    
# Both limitation can be overcome with:
#   - Nginx or HAProxy LB proxy, or:
#   - Docker Enterprise Edition, which comes with built-in L4 web proxy

# More references:
# https://docs.docker.com/engine/swarm/ingress/
# https://success.docker.com/Architecture/Docker_Reference_Architecture%3A_Universal_Control_Plane_2.0_Service_Discovery_and_Load_Balancing
# https://medium.com/@lherrera/solving-the-routing-mess-for-services-in-docker-73492c37b335
