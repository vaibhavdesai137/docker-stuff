
# REMEMBER, SECRETS WORK ONLY WITH SWARM. 

# So how do we get this working in local since there is no swarm?
# Docker does it by default by doing some magic.
# In local, instead of creating secrets, docker simply reads the yml file and bind mounts our local files using "-v" to the container
# Super incsecure but works in local for quick testing.
# The advantage is we can use same scripts in DEV and PROD. No need to write custom compose files in dev because swarm doesn't exist.

# ***** GOTCHAS ******
# Can only work with file based secrets and not externals.
# Becoz thats the only way to bind mount using -v when spinning up the container.
# If prod uses external secrets, then you may need a separate compose for dev.

# verify that local does not have swarm
docker node ls
# Error response from daemon: This node is not a swarm manager. Use "docker swarm init" or "docker swarm join" to connect this node to swarm and try again.

ls -l
# total 32
# -rw-r--r--  1 vaidesai  110139996   369 Aug 28 23:10 postgres-compose.yml
# -rw-r--r--  1 vaidesai  110139996    10 Aug 28 23:22 postgres_password.txt
# -rw-r--r--  1 vaidesai  110139996     6 Aug 28 23:22 postgres_user.txt

# start the containers
docker-compose -f postgres-compose.yml up -d
# Starting 18dockercomposelocallywithsecrets_postgres_1 ... 
# Starting 18dockercomposelocallywithsecrets_postgres_1 ... done

# verify container is up
docker container ls
# CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS              PORTS               NAMES
# 658a35339b54        postgres            "docker-entrypoint..."   About a minute ago   Up About a minute   5432/tcp            18dockercomposelocallywithsecrets_postgres_1

docker exec -it 658a35339b54 bash
cd /run/secrets/
ls -l
# total 8
# -rw-r--r-- 1 root root 10 Aug 29 06:22 postgres_password
# -rw-r--r-- 1 root root  6 Aug 29 06:22 postgres_user

# 
# DIFFERENT THAN PREVIOUS PROJECT
# 
# WHEN WE REMOVED THE SERVICE MANUALLY, SECRETS WERE NOT REMOVED BY DEFAULT.
# BUT HERE, BCOZ THE SECRETS ARE A PART OF THE STACK ITSELF, THEY WILL BE REMOVED WHEN THE STACK GOES AWAY
#

# remove the stack
docker stack rm postgres
# Removing service postgres_postgres
# Removing secret postgres_postgres_user
# Removing secret postgres_postgres_password
# Removing network postgres_default

# no service should be running
docker service ls

# no containers should be running
docker container ps

# ******* NOTE *******
# For prod envs, NEVER use local files or stdins (these get captured in bash history) for secrets. This destroys the whole purpose of having secrets
# Fetch the secrets remotely via API or whatever
# Whatever the mthod to fetch secrets, always remember to cleanup after the service is destroyed