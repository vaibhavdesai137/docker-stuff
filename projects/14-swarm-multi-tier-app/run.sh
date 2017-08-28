
# SWARM is the orchestration engine for docker

# setup ssh keys in dgitalocean for root access
# https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa_digitalocean

# use csshX to login on all
./csshX --ssh_args "-i /Users/vaidesai/.ssh/id_rsa_digitalocean" --login root 138.68.246.21 138.68.57.141 138.197.192.14 

# Look at README.md in this directory to understand the project structure

# 2 overlay networks
docker network create --driver overlay backend
docker network create --driver overlay frontend

# 5 docker services with replicas
docker service create --name vote --network frontend --replicas 2 -p 80:80 -d dockersamples/examplevotingapp_vote:before
docker service create --name redis --network frontend --replicas 2 -d redis:3.2
docker service create --name worker --network frontend --network backend -d dockersamples/examplevotingapp_worker
docker service create --name db --network backend --mount type=volume,source=db-data,target=/var/lib/postgresql/data -d postgres:9.4
docker service create --name result --network backend -p 5001:80 -d dockersamples/examplevotingapp_result:before

# verify all services are up (and check the replicas too)
# docker service ls
# ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
# 1y4zgagm3736        redis               replicated          2/2                 redis:3.2                                      
# j2uwsuxzx6t9        db                  replicated          1/1                 postgres:9.4                                   
# j9tdp7h99ma2        worker              replicated          1/1                 dockersamples/examplevotingapp_worker:latest   
# mz1rooelffwf        result              replicated          1/1                 dockersamples/examplevotingapp_result:before   *:5001->80/tcp
# srjrb1uvmkvs        vote                replicated          2/2                 dockersamples/examplevotingapp_vote:before     *:80->80/tcp

# test our voting app
# hit any ip and make sure you get the app home page
# http://138.68.246.21

# test our result app
# hit any ip on port 5001 and make sure you get the app home page
# http://138.68.246.21:5001
# this does not work on digitalocean since they do not expose any port other than 80 by default
# need some custom circus to get this going

# remove all networks
docker network rm frontend
docker network rm backend

# remove all services
docker service rm vote
docker service rm redis
docker service rm worker
docker service rm db
docker service rm result

# no service should be running
docker service ls

# no containers should be running
docker container ps

