FROM resin/rpi-raspbian  

RUN apt-get update && apt-get -qy install apt-utils apt-transport-https wget build-essential
RUN wget -qO - https://debian.fhem.de/archive.key | apt-key add - && echo "deb http://debian.fhem.de/nightly/ /" > /etc/apt/sources.list.d/fhem.list
RUN apt-get update && apt-get -qy install fhem 

# use cpanm because of memory issues with cpan
RUN curl -L http://cpanmin.us | perl - --self-upgrade
RUN cpanm -i Net::MQTT::Simple Net::MQTT::Constants Module::Pluggable

WORKDIR /opt/fhem

COPY fhem.cfg ./fhem.cfg
RUN echo "attr global nofork 1" >> fhem.cfg
COPY start.sh ./start.sh
RUN ["chmod", "+x", "./start.sh"]

RUN userdel fhem 

EXPOSE 8083
EXPOSE 7072
# mount /opt/fhem/log to /var/log/fhem to have the logs outside the container
# similarly the fhem.cfg could be hosted outside
CMD ["./start.sh"]
