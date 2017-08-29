
# SWARM is the orchestration engine for docker

# setup ssh keys in dgitalocean for root access
# https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa_digitalocean

# use csshX to login on all
./csshX --ssh_args "-i /Users/vaidesai/.ssh/id_rsa_digitalocean" --login root 138.68.246.21 138.68.57.141 138.197.192.14 

# Unlike prev proj where we created the service manually, we'll do the same using stacks
# Look up the .yml file to see how secrets are passed in to the service
# https://docs.docker.com/compose/compose-file/#secrets-configuration-reference

# deploy the stack
ls -l
# total 32
# -rw-r--r-- 1 root root   370 Aug 29 05:55 postgres-compose.yml
# -rw-r--r-- 1 root root    11 Aug 29 05:54 postgres_password.txt
# -rw-r--r-- 1 root root     7 Aug 29 04:51 postgres_user.txt

docker stack deploy -c postgres-compose.yml postgres
# Creating secret postgres_user
# Creating secret postgres_password
# Creating network postgres_default
# Creating service postgres_postgres

# verify postgres is up
docker service ls
# ID                  NAME                MODE                REPLICAS            IMAGE               PORTS
# j70u94v3fjcr        postgres_postgres   replicated          1/1                 postgres:9.4        

# just liek prev proj, you can bash to the container and verify that secrets exist

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