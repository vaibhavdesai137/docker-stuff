
# SWARM is the orchestration engine for docker

# setup ssh keys in dgitalocean for root access
# https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa_digitalocean

# use csshX to login on all
./csshX --ssh_args "-i /Users/vaidesai/.ssh/id_rsa_digitalocean" --login root 138.68.246.21 138.68.57.141 138.197.192.14 

# https://docs.docker.com/engine/swarm/secrets/

# Easiest "secure" solution for storing secrets in Swarm
# What is a Secret?
    # Usernames and passwords
    # TLS certificates and keys
    # SSH keys
    # Any data you would prefer not be "on front page of news"
# Supports generic strings or binary content up to 500Kb in size
# Doesn't require apps to be rewritten
# As of Docker 1.13.0 Swarm Raft DB is encrypted on disk
# Only stored on disk on Manager nodes
# Default is Managers and Workers "control plane" is TLS + Mutual Auth
# Secrets are first stored in Swarm, then assigned to a Service(s)
# Only containers in assigned Service(s) can see them
# They look like files in container but are actually in-memory fs
# /run/secrets/<secret_name> or /run/secrets/<secret_alias>
# Local docker-compose can use file-based secrets, but not secure

# when we usually start our postgres, we pass user and password on cmd line
# using secrets, we can avoid that

# create secret called "postgres_user" using file
# cat postgres_user.txt 
# myuser 
docker secret create postgres_user postgres_user.txt

# create secret "postgres_password" using stdin
# "-" tells docker to read value for the secret using stdin
echo "mypassword" | docker secret create postgres_password - 
docker stack deploy -c voteapp.yml voteapp

# verify secrets were created
docker secret ls
# ID                          NAME                CREATED             UPDATED
# lfpx9j6c37x25x99b4m6ujafy   postgres_user       33 seconds ago      33 seconds ago
# wk3tl5ix9hl8dxy01afxmz9tl   postgres_password   28 seconds ago      28 seconds ago

# inspect a secret to verify the contents are not revealed
# ofcourse, otherwise that would ruin the whole purpos eof having secrets :-p
docker secret inspect postgres_user
# docker secret inspect postgres_user
# [
#   {
#       "ID": "lfpx9j6c37x25x99b4m6ujafy",
#       "Version": {
#           "Index": 2756
#       },
#       "CreatedAt": "2017-08-29T04:53:44.086629419Z",
#       "UpdatedAt": "2017-08-29T04:53:44.086629419Z",
#       "Spec": {
#           "Name": "postgres_user",
#           "Labels": {}
#       }
#   }
# ]


# create a new postgres db that uses secrets to init the user and pwd
# by default, only service that was passed the secret flag will have access to that service
docker service create --name postgres --secret postgres_user --secret postgres_password -e POSTGRES_USER_FILE=/run/secrets/postgres_user -e POSTGRES_PASSWORD_FILE=/run/secrets/postgres_password -d postgres

# verify posgres is up
docker service ls
# ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
# imxkqsm50tkd        postgres            replicated          1/1                 postgres:latest     

# bash to the container and verify the secrets exist
docker container ls
# CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS               NAMES
# a6f7073eb5d0        postgres:latest     "docker-entrypoint..."   2 minutes ago       Up 2 minutes        5432/tcp            postgres.1.lxaapwz0csqkbohvvy7ksb3ba

docker exec -it a6f7073eb5d0 bash
cd /run/secrets/
ls -l
# total 8
# -r--r--r-- 1 root root 11 Aug 29 05:37 postgres_password
# r--r--r-- 1 root root  7 Aug 29 05:37 postgres_user
cat postgres_password 
# mypassword
cat postgres_user 
# myuser

# 
# SECRETS ARE IMMUTABLE PART OF THE SERVICE.
# IF YOU REMOVE A SECRET USING UPDATE, THEN SERVICE WILL BE REDPELOYED.
# AND SINCE THE USER IS NO LONGER PROVIDED, POSTGRES WILL NOT COME UP.
# ANY CHANGES MADE TO A SERVICE WILL NEVER BE APPLIED DIRECTLY TO THE CONTAINER.
# 
docker service update --secret-rm postgres_user postgres

# verify that postgres is down after removing the key from that service
docker service update --secret-rm postgres_user postgres
docker service ls
# ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
# imxkqsm50tkd        postgres            replicated          0/1                 postgres:latest     

# from docker logs:
# LOG:  autovacuum launcher started
# done
# server started
# /usr/local/bin/docker-entrypoint.sh: line 20: /run/secrets/postgres_user: No such file or directory

# remove the secrets
docker secret rm postgres_user
docker secret rm postgres_password

# remove the service
docker service rm postgres

# no service should be running
docker service ls

# no containers should be running
docker container ps

