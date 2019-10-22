#===========
#Build Stage
#===========
FROM bitwalker/alpine-elixir:1.5 as build

#Copy the source folder into the Docker image
COPY . .

RUN pwd
RUN ls

#Install dependencies and build Release
RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    mix deps.get && \
    mix release
    
RUN ls _build/prod/rel/clock/

#Extract Release archive to /rel for copying in next stage
RUN APP_NAME="clock" && \
    RELEASE_DIR=`ls -d _build/prod/rel/$APP_NAME/releases/*/` && \
    mkdir /export && \
    tar -xf "$RELEASE_DIR/$APP_NAME.tar.gz" -C /export

#================
#Deployment Stage
#================
FROM pentacent/alpine-erlang-base:latest

#Set environment variables and expose port
EXPOSE 4000
ENV REPLACE_OS_VARS=true \
    PORT=4000

#Copy and extract .tar.gz Release file from the previous stage
COPY --from=build /export/ .

#Change user
USER default

#Set default entrypoint and command
ENTRYPOINT ["/opt/app/bin/MY_APP_NAME"]
CMD ["foreground"]
