
# SWARM is the orchestration engine for docker

# setup ssh keys in dgitalocean for root access
# https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa_digitalocean

# use csshX to login on all
./csshX --ssh_args "-i /Users/vaidesai/.ssh/id_rsa_digitalocean" --login root 138.68.246.21 138.68.57.141 138.197.192.14 

# Deploying drupal/postgres as a docker stack with secrets

# create 3 secrets
echo "mydb" | docker secret create postgres_db - 
echo "myuser" | docker secret create postgres_user - 
echo "mypassword" | docker secret create postgres_password - 

# verify secrets are created
docker secret ls
# ID                          NAME                CREATED             UPDATED
# 5xip4sz9nxdya7553gliw5bea   postgres_user       5 minutes ago       5 minutes ago
# bv5atpwowa7v6c6q31jwu9cbn   postgres_db         5 minutes ago       5 minutes ago
# ohe4ohtfo24gup2ppubpauaf0   postgres_password   9 minutes ago       9 minutes ago

# deploy the stack using the yml
# see how secrets are passed to postgres using "external"
# "external" because we created them manually outside of yml file
ls -l
# total 4
# -rw-r--r-- 1 root root 1022 Aug 30 03:36 mydrupal-compose.yml

docker stack deploy -c mydrupal-compose.yml mydrupal
# Creating network mydrupal_default
# Creating service mydrupal_drupal
# Creating service mydrupal_postgres

# verify everything is good
docker stack ps mydrupal
# ID                  NAME                  IMAGE               NODE                DESIRED STATE       CURRENT STATE                ERROR               PORTS
# uwsd10ui0pq4        mydrupal_postgres.1   postgres:9.6        node2               Running             Running about a minute ago                       
# sms1w85t4jnj        mydrupal_drupal.1     drupal:8.2          node3               Running             Running about a minute ago                       
# tfnn7d72aogl        mydrupal_postgres.2   postgres:9.6        node3               Running             Running about a minute ago                       
# ito5ktv2vini        mydrupal_drupal.2     drupal:8.2          node1               Running             Running about a minute ago                       
# h9u3ktmbt8qn        mydrupal_postgres.3   postgres:9.6        node1               Running             Running about a minute ago                       
# sst5p77je39o        mydrupal_drupal.3     drupal:8.2          node2               Running             Running about a minute ago                       

# remove all secrets
docker secret rm postgres_db
docker secret rm postgres_user
docker secret rm postgres_password

# remove the stack
docker stack rm postgres
# Removing service mydrupal_drupal
# Removing service mydrupal_postgres
# Removing network mydrupal_default

# no service should be running
docker service ls

# no containers should be running
docker container ps


