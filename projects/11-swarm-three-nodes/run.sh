
# SWARM is the orchestration engine for docker

# create 3 docklets in digitalocean
# 138.68.246.21 (node1) 
# 138.68.57.141 (node2)
# 138.197.192.14 (node3)

# setup ssh keys in dgitalocean for root access
# https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
# eval `ssh-agent -s`
# ssh-add ~/.ssh/id_rsa_digitalocean

# use csshX to login on all
# ./csshX --ssh_args "-i /Users/vaidesai/.ssh/id_rsa_digitalocean" --login root 138.68.246.21 138.68.57.141 138.197.192.14 

# install docker on all
# curl -fsSL get.docker.com -o get-docker.sh
# sh get-docker.sh

# init docker swarm on node1 (needs ip address)
# node1 becomes leader (and manager) by default since we ran init here first
# docker swarm init --advertise-addr 138.68.246.21

# add other two nodes to the swarm as workers
# docker swarm join --token SWMTKN-1-42wzgxfp89rt08q2pojtz6yn1cbzzoptdq10yfzjwkfwlq3gmy-3c1x8eocg3eow7eudzhmojde7 138.68.246.21:2377
# docker swarm join --token SWMTKN-1-42wzgxfp89rt08q2pojtz6yn1cbzzoptdq10yfzjwkfwlq3gmy-3c1x8eocg3eow7eudzhmojde7 138.68.246.21:2377

#
# AT THIS POINT, WE HAVE 3 SWARMS (1 MANAGER and 2 WORKERS, BUT ALL 3 CAN RUN CONTAINERS)
# TECHNICALLY, ALL DOCKER COMMANDS CAN BE RUN FROM THE LEADER NODE
# BUT ONLY LEADER CAN RUN SWARM RELATED COMMANDS
# YOU CAN ALSO MAKE ALL 3 NODES AS MANAGERS SINCE MANAGER CAN BE WORKERS TOO SO YOU CAN RUN SWARM COMMANDS FROM ALL NODES
#

# verify that nodes are up and reporting status correctly
# docker node ls
# ID                            HOSTNAME            STATUS              AVAILABILITY        MANAGER STATUS
# 6pi5q4vfmlq1q5iimnglbkzqu *   node1               Ready               Active              Leader
# lrkq7r0y91x336g5cd3rfbxzk     node3               Ready               Active              
# ua178r2db3h6qjff9jhvw1dxe     node2               Ready               Active              

# update all nodes to be managers
# only node1 can run these commands since node1 is the only manager
# docker node update --role manager node2
# docker node update --role manager node3

#
# ALL NODES ARE NOW READY TO SPIN UP CONTAINERS
#

# create a new service and all that will do is ping
# since we have 3 nodes, we'll star with 3 replicas so each node will run one container
# docker service create --replicas 3 alpine ping 8.8.8.8

# verify service is up (note how it says 3/3 replicas)
# docker service ls
# ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
# ala2ahdiipk8        happy_bhaskara      replicated          3/3                 alpine:latest 

# verify each node is running one container
# docker service ps ala2ahdiipk8
# ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE           ERROR               PORTS
# jx7tdpbx60o4        happy_bhaskara.1    alpine:latest       node2               Running             Running 3 minutes ago                       
# iqyojz7vyku0        happy_bhaskara.2    alpine:latest       node3               Running             Running 3 minutes ago                       
# 0uy52ut9185n        happy_bhaskara.3    alpine:latest       node1               Running             Running 3 minutes ago                       

# update to 6 replicas
# we had 3 replicas running so 3 new replicas will be spun up
# since we have 3 workers total, each node will now run 2 containers
# docker service update ala2ahdiipk8 --replicas 6

# verify each node is running 2 containers
# docker service ps ala2ahdiipk8
# ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE           ERROR               PORTS
# jx7tdpbx60o4        happy_bhaskara.1    alpine:latest       node2               Running             Running 5 minutes ago                       
# iqyojz7vyku0        happy_bhaskara.2    alpine:latest       node3               Running             Running 5 minutes ago                       
# 0uy52ut9185n        happy_bhaskara.3    alpine:latest       node1               Running             Running 5 minutes ago                       
# wsfgx9vpmd2n        happy_bhaskara.4    alpine:latest       node2               Running             Running 6 seconds ago                       
# rkgquvhbjsa7        happy_bhaskara.5    alpine:latest       node3               Running             Running 6 seconds ago                       
# h26t9otqzfdh        happy_bhaskara.6    alpine:latest       node1               Running             Running 6 seconds ago 

# go to any node and kill 1 container
# docker container rm -f 0uy52ut9185n

# swarm realizes we needed 6 replicas so it will spin one up automatically on the node that we killed the container on
# rfcjy48uaum0 is the new container swarm created to maintain 6 replicas
# docker service ps ala2ahdiipk8
# ID                  NAME                   IMAGE               NODE                DESIRED STATE       CURRENT STATE               ERROR                         PORTS
# jx7tdpbx60o4        happy_bhaskara.1       alpine:latest       node2               Running             Running 7 minutes ago                                     
# iqyojz7vyku0        happy_bhaskara.2       alpine:latest       node3               Running             Running 7 minutes ago                                     
# rfcjy48uaum0        happy_bhaskara.3       alpine:latest       node1               Running             Running 54 seconds ago                                    
# 0uy52ut9185n         \_ happy_bhaskara.3   alpine:latest       node1               Shutdown            Failed about a minute ago   "task: non-zero exit (137)"   
# wsfgx9vpmd2n        happy_bhaskara.4       alpine:latest       node2               Running             Running 2 minutes ago                                     
# rkgquvhbjsa7        happy_bhaskara.5       alpine:latest       node3               Running             Running 2 minutes ago                                     
# h26t9otqzfdh        happy_bhaskara.6       alpine:latest       node1               Running             Running 2 minutes ago                                     

# remove the service
# docker service rm ala2ahdiipk8

# no service should be running
# docker service ls

# no containers should be running
# docker container ps

