# . = build context (where the docker file is)
# When the docker file is called Dockerfile it's not necessary to mention the file name
# Build: docker build -f node.dockerfile -t image_name .
# Build: docker build -t registry_name/image_name:1.0 .

# Option 1: Create a custom bridge network and add containers into it
# Communication between containers = bridge network
# There are other solutions for communication between containers, bridge is the easiest
# docker network create --driver bridge isolated_network
# docker run -d --net=isolated_network --name mongodb mongo

# NOTE: $(pwd) in the following line is for Mac and Linux. Use ${PWD} for Powershell. 
# See https://blog.codewithdan.com/docker-volumes-and-print-working-directory-pwd/ syntax examples.
# docker run -d --net=isolated_network --name nodeapp -p 3000:3000 -v $(pwd)/logs:/var/www/logs nodeapp

# Seed the database with sample database
# Run: docker exec nodeapp node dbSeeder.js

# Option 2 (Legacy Linking - this is the OLD way)
# Start MongoDB and Node (link Node to MongoDB container with legacy linking)
 
# docker run -d --name my-mongodb mongo
# docker run -d -p 3000:3000 --link my-mongodb:mongodb --name nodeapp danwahlin/nodeapp

# /!\ Better to be explicit on the version in a professional environement! Ex node:15.9.0-alpine
FROM        node:alpine

# Just meta-data (any key)
LABEL       author="Dan Wahlin"

ARG         PACKAGES=nano

# => NODE_ENV, PORT -> Moved to the docker-compose file
ENV         NODE_ENV=production
ENV         PORT=3000
ENV         TERM xterm
RUN         apk update && apk add $PACKAGES

# From now on, it's the working directory
# => we don't have to mention it everytime in the path of files/folers
WORKDIR     /var/www
COPY        package*.json ./
RUN         npm install

# From current (local) folder to working directory
# Use dockerignore file to avoid copying heavy files like node_modules
COPY        . ./
# Reuse port env variable defined at line 31
#EXPOSE      $PORT
EXPOSE      3000

# What to run when it starts up
ENTRYPOINT  ["npm", "start"]
