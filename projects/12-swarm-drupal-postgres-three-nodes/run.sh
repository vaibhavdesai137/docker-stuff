
# SWARM is the orchestration engine for docker

# setup ssh keys in dgitalocean for root access
# https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
# eval `ssh-agent -s`
# ssh-add ~/.ssh/id_rsa_digitalocean

# use csshX to login on all
# ./csshX --ssh_args "-i /Users/vaidesai/.ssh/id_rsa_digitalocean" --login root 138.68.246.21 138.68.57.141 138.197.192.14 

# create overlay network, should reflect all on swarm nodes
# docker network create --driver overlay mydrupal

# start postgres and drupal container on our overlay network
# note that we nare not specifying any replicas (default 1)
# docker service create --name postgres --network mydrupal -e POSTGRES_USER=myuser -e POSTGRES_PASSWORD=mypassword -e POSTGRES_DB=mydb postgres
# docker service create --name drupal --network mydrupal -p 80:80 drupal

# verify drupal/postgres are up (notice just 1 replica)
# docker service ls
# ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
# ohph102hu5aq        drupal              replicated          1/1                 drupal:latest       *:80->80/tcp
# pgbnw2lnrs9d        postgres            replicated          1/1                 postgres:latest

# check which nodes are running what containers
# see postgres is running on node2 and drupal on node3
# docker service ps postgres
# ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE           ERROR               PORTS
# se8hry9iw4hp        postgres.1          postgres:latest     node2               Running             Running 46 seconds ago                       
# docker service ps drupal
# ID                  NAME                IMAGE               NODE                DESIRED STATE       CURRENT STATE                ERROR               PORTS
# odu9l3264lf6        drupal.1            drupal:latest       node3               Running             Running about a minute ago                       

#
# HOW WILL THEY TALK TO EACH OTHER? 
# They can because we gave the same network to them while creating the service
# The power of overlay network driver
# Think of overlay network as a virtual network between all swarm nodes
# more on MESG ROUTING in the next project
#

# test our drupal website is reachable
# since node2 and node3 are running postgres and drupal, hit node1 just for fun
# open browser and hit http://138.68.246.21/ (node1)
# you should see drupal site load up

# remove the service
# docker service rm postgres
# docker service rm drupal

# no service should be running
# docker service ls

# no containers should be running
# docker container ps

