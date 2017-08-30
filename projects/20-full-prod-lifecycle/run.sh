
# SWARM is the orchestration engine for docker

# setup ssh keys in dgitalocean for root access
# https://www.digitalocean.com/community/tutorials/how-to-use-ssh-keys-with-digitalocean-droplets
eval `ssh-agent -s`
ssh-add ~/.ssh/id_rsa_digitalocean

# use csshX to login on all
./csshX --ssh_args "-i /Users/vaidesai/.ssh/id_rsa_digitalocean" --login root 138.68.246.21 138.68.57.141 138.197.192.14 

#
# For this project, we'll do a full lifecyle of a docker app like we would do in real world
#

#
# Dockerfile
#      - Specifies how to build the image
#      
# docker-compose.override.yml
#      - Sets the defaults that are same across all envs
#      - By default imported by docker engine as long as it is named as "docker-compose.override.yml"
#      - Uses "file" for secrets as default because for local, there is no swarm, so only "file" secrets can be used
# 
# docker-compose.yml
#      - For local env
#      - Only specifies what images to use
#      - Default parameters come from docker-compose.override.yml
#      - All dev specific parameters can go here
#      - You can name it docker-compose.dev.yml but then you will need -f flag to let docker-compose know
#
# docker-compose.test.yml
#      - For CI/test env
#      - Note how there is a "build" in this file. This is because we want our CI to always build a new image everytime a change is made.
#      - No volumes are specified because we don't want to store anything since this is a test env
#      - Also note the "./smaple-data" in volumes. This is because we may want to use already created db files for testing rather than creating it every time we test
#
# docker-compose.prod.template.yml
#      - For prod env
#      - Remember, there is no docker-compose for prod
#      - We only want to deploy our stack/services/containers here. We do not want to build anything
#      - We should use an already created image
#      - *** WE SIMPLY NEED TO CREATE THE .YML FILE NEEDED FOR PROD DEPLOY *** 
#      - We specify the "deploy" tags that say how many containers we want and stuff
#      - Also, note that for prod, we want "external" secrets so that we don't copy paste password files on prod boxes
#      - This means we have to create secrets using "docker secret create" via scripts/manually

ls -l
# total 64
# -rw-r--r--  1 vaidesai  110139996   301 Aug 21 23:33 Dockerfile
# -rw-r--r--  1 vaidesai  110139996   129 Aug 29 22:20 docker-compose.yml
# -rw-r--r--  1 vaidesai  110139996   934 Aug 29 22:14 docker-compose.override.yml
# -rw-r--r--  1 vaidesai  110139996  1024 Aug 29 22:29 docker-compose.prod.template.yml
# -rw-r--r--  1 vaidesai  110139996   601 Aug 29 22:08 docker-compose.test.yml
# -rw-r--r--  1 vaidesai  110139996     4 Aug 29 22:47 postgres_db.txt
# -rw-r--r--  1 vaidesai  110139996    10 Aug 29 22:47 postgres_password.txt
# -rw-r--r--  1 vaidesai  110139996     6 Aug 29 22:47 postgres_user.txt
# -rwxrwxrwx  1 vaidesai  110139996  4692 Aug 29 22:28 run.sh
# drwxr-xr-x  2 vaidesai  110139996    68 Aug 29 21:58 themes

# ******************
# DEV
# ******************

docker-compose up -d
# Starting 20fullprodlifecycle_drupal_1 ... 
# Starting 20fullprodlifecycle_postgres_1 ... 
# Starting 20fullprodlifecycle_postgres_1
# Starting 20fullprodlifecycle_drupal_1 ... done

docker container ls
# CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                  NAMES
# f7d627dd7f95        custom-drupal       "docker-php-entryp..."   13 seconds ago      Up 11 seconds       0.0.0.0:80->80/tcp   20fullprodlifecycle_drupal_1
# 3c7dcb3d2b26        postgres:9.6        "docker-entrypoint..."   13 seconds ago      Up 11 seconds       5432/tcp               20fullprodlifecycle_postgres_1

# Hit http://localhost to see drupal up and running
# "inspect" the containers to see how it created mounts and used port 80 from our override file

docker-compose down -v
# Stopping 20fullprodlifecycle_postgres_1 ... done
# Stopping 20fullprodlifecycle_drupal_1 ... done
# Removing 20fullprodlifecycle_postgres_1 ... done
# Removing 20fullprodlifecycle_drupal_1 ... done
# Removing network 20fullprodlifecycle_default
# Removing volume 20fullprodlifecycle_drupal-modules
# Removing volume 20fullprodlifecycle_drupal-sites
# Removing volume 20fullprodlifecycle_drupal-profiles
# Removing volume 20fullprodlifecycle_drupal-themes
# Removing volume 20fullprodlifecycle_drupal-data

# ******************
# TEST
# ******************

docker-compose -f docker-compose.yml -f docker-compose.test.yml up -d
# Creating network "20fullprodlifecycle_default" with the default driver
# Creating 20fullprodlifecycle_postgres_1 ... 
# Creating 20fullprodlifecycle_drupal_1 ... 
# Creating 20fullprodlifecycle_postgres_1 ... done

docker container ls
# CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                NAMES
# 4e3bd1282df8        postgres:9.6        "docker-entrypoint..."   8 seconds ago       Up 6 seconds        5432/tcp             20fullprodlifecycle_postgres_1
# 72fb1e58952d        custom-drupal       "docker-php-entryp..."   8 seconds ago       Up 6 seconds        0.0.0.0:80->80/tcp   20fullprodlifecycle_drupal_1

# Hit http://localhost to see drupal up and running
# "inspect" the containers to see how there are NO mounts (our test yml explicitly said no mounts)

docker-compose -f docker-compose.yml -f docker-compose.test.yml down -v
# Stopping 20fullprodlifecycle_postgres_1 ... done
# Stopping 20fullprodlifecycle_drupal_1 ... done
# Removing 20fullprodlifecycle_postgres_1 ... done
# Removing 20fullprodlifecycle_drupal_1 ... done
# Removing network 20fullprodlifecycle_default

# ******************
# PROD
# ******************

# Create the prod yml file that will be shipped on our prod boxes
# Running "config" merges all the yml files, we name it docker-compose.prod.yml
# And this new yml file should be used to bring up services in prod
# Note that we were using custom-drupal image for dev/test. This will not work in prod since we did not upload it to docker hub
# Ideally, the CI should upload the image to private docker hub where the prod boxes will download from.
# In this case, just edit the final yml file to use a public image so we can test our yml files on digital ocean servers

docker-compose -f docker-compose.yml -f docker-compose.prod.template.yml config > docker-compose.prod.yml

# create 3 secrets
# this is needed because our prod yml says use "external" for secrets
echo "mydb" | docker secret create postgres_db - 
echo "myuser" | docker secret create postgres_user - 
echo "mypassword" | docker secret create postgres_password - 

# verify secrets are created
docker secret ls
# ID                          NAME                CREATED             UPDATED
# 5xip4sz9nxdya7553gliw5bea   postgres_user       5 minutes ago       5 minutes ago
# bv5atpwowa7v6c6q31jwu9cbn   postgres_db         5 minutes ago       5 minutes ago
# ohe4ohtfo24gup2ppubpauaf0   postgres_password   9 minutes ago       9 minutes ago

docker stack deploy -c docker-compose.prod.yml mydrupal
# Ignoring unsupported options: build
# Creating network mydrupal_default
# Creating service mydrupal_drupal
# Creating service mydrupal_postgres

# verify everything is good
docker stack ps mydrupal
# ID                  NAME                  IMAGE               NODE                DESIRED STATE       CURRENT STATE                ERROR               PORTS
# obshe23l22zt        mydrupal_postgres.1   postgres:9.6        node1               Running             Running about a minute ago                       
# 5hpshfzq1mj8        mydrupal_drupal.1     drupal:8.2          node1               Running             Running about a minute ago                       
# mop7nxyxqj9v        mydrupal_postgres.2   postgres:9.6        node2               Running             Running about a minute ago                       
# h0bqeod91sxd        mydrupal_drupal.2     drupal:8.2          node2               Running             Running about a minute ago                       
# kd7l7rautrw1        mydrupal_postgres.3   postgres:9.6        node3               Running             Running about a minute ago                       
# 1ufbijl0h7n5        mydrupal_drupal.3     drupal:8.2          node3               Running             Running about a minute ago                       

# Hit http://node1 to see drupal up and running
# "inspect" the containers to see how our prod configs were used from our prod.template.yml file

# remove the stack
docker stack rm mydrupal
# Removing service mydrupal_postgres
# Removing service mydrupal_drupal
# Removing network mydrupal_default

# remove all secrets
docker secret rm postgres_db
docker secret rm postgres_user
docker secret rm postgres_password

# no service should be running
docker service ls

# no containers should be running
docker container ps


