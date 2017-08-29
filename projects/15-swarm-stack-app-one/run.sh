
# SWARM is the orchestration engine for docker

# setup ssh keys in dgitalocean for root access
# https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa_digitalocean

# use csshX to login on all
./csshX --ssh_args "-i /Users/vaidesai/.ssh/id_rsa_digitalocean" --login root 138.68.246.21 138.68.57.141 138.197.192.14 

# Look at README.md in this directory to understand the project structure
# We implemented the above using individual docker services
# But in this project, we will do the same using docker stacks

# In 1.13 Docker adds a new layer of abstraction to Swarm called Stacks
# Stacks accept Compose files as their declarative definition for services, networks, and volumes
# We use docker stack deploy rather then docker service create
# Stacks manages all those objects for us, including overlay network per stack. Adds stack name to start of their name
# New deploy: key in Compose file. Can't do build:
# Compose now ignores deploy:, Swarm ignores build: 
# docker-compose cli not needed on Swarm server

# create the stack based on yml file
# stack will be named as voteapp 
docker stack deploy -c voteapp.yml voteapp

# verify all services in the stack are up (and check the replicas too)
docker stack services voteapp
# ID                  NAME                 MODE                REPLICAS            IMAGE                                          PORTS
# 8sz60t1be343        voteapp_visualizer   replicated          1/1                 dockersamples/visualizer:stable                *:8080->8080/tcp
# j2ttiyn3hb3k        voteapp_worker       replicated          1/1                 dockersamples/examplevotingapp_worker:latest   
# s8awwgd1wyse        voteapp_db           replicated          1/1                 postgres:9.4                                   
# sdjyxnohmux1        voteapp_vote         replicated          2/2                 dockersamples/examplevotingapp_vote:before     *:5000->80/tcp
# uzf9if97gtpb        voteapp_redis        replicated          2/2                 redis:alpine                                   *:0->6379/tcp
# zb36xlzsigzm        voteapp_result       replicated          1/1                 dockersamples/examplevotingapp_result:before   *:5001->80/tcp

# verify all services in the stack are up (and check the replicas too)
docker stack ps voteapp
# ID                  NAME                   IMAGE                                          NODE                DESIRED STATE       CURRENT STATE                ERROR                       PORTS
# uvhgxvy1gnj3        voteapp_redis.1        redis:alpine                                   node1               Running             Running about a minute ago                               
# yoxifuyi3sbg        voteapp_worker.1       dockersamples/examplevotingapp_worker:latest   node1               Running             Running about a minute ago                               
# 7cc727ba9o9z        voteapp_visualizer.1   dockersamples/visualizer:stable                node3               Running             Running about a minute ago                               
# 0e87dbexqfw1        voteapp_result.1       dockersamples/examplevotingapp_result:before   node2               Running             Running about a minute ago                               
# 7okleq6bz3v3        voteapp_vote.1         dockersamples/examplevotingapp_vote:before     node2               Running             Running about a minute ago                               
# snz6fmemw7an        voteapp_db.1           postgres:9.4                                   node3               Running             Running about a minute ago                               
# 4v3a4s3dpehd        voteapp_redis.2        redis:alpine                                   node2               Running             Running about a minute ago                               
# 7rj5z5nd40j7        voteapp_vote.2         dockersamples/examplevotingapp_vote:before     node1               Running             Running about a minute ago                               

# verify that new overlay networks were created for this app
docker network ls
# NETWORK ID          NAME                DRIVER              SCOPE
# ...
# ...
# q4g5ak2ytkct        voteapp_backend     overlay             swarm
# qsheeq7prjro        voteapp_default     overlay             swarm
# sjs0runghhpe        voteapp_frontend    overlay             swarm
# ...
# ...

# verify our apps are up
http://138.197.192.14:5000 (voting app)
http://138.197.192.14:5001 (results app)
http://138.197.192.14:8080 (visualizer app, gives a nice visual view of our swarm nodes, see the screensot file visualizer.png)

# remove the stack
docker stack rm voteapp

# no service should be running
docker service ls

# no containers should be running
docker container ps

