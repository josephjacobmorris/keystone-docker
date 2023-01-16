FROM ubuntu:22.04

LABEL maintainer="josephjacob1998@gmail.com"

EXPOSE 5000

LABEL description="Openstack Keystone Docker Image Supporting HTTP/HTTPS for Soda Foundation"

RUN apt-get -y update  && apt-get install -y software-properties-common && add-apt-repository cloud-archive:zed && apt remove -y software-properties-common && apt-get -y clean && apt autoremove -y
RUN export DEBIAN_FRONTEND="noninteractive" && apt-get -y update && apt-get install -y python3-openstackclient keystone && apt-get -y clean
COPY entrypoint.sh /entrypoint.sh
COPY ./keystone.policy.json /etc/keystone/policy.json
CMD sh -x /entrypoint.sh
