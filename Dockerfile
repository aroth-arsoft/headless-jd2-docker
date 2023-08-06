FROM openjdk:21-ea-22-slim-buster

ENV LC_CTYPE="en_US.UTF-8" \
	LANG="en_US.UTF-8" \
	LC_COLLATE="C" \
	LANGUAGE="C.UTF-8" \
	LC_ALL="C.UTF-8"

# Create directory, and start JD2 for the initial update and creation of config files.
RUN apt-get update && \
	apt-get install -yqq tini ffmpeg wget make gcc jq && \
	mkdir -p /opt/JDownloader/libs && \
	wget -O /opt/JDownloader/JDownloader.jar --user-agent="https://hub.docker.com/r/plusminus/jdownloader2-headless/" http://installer.jdownloader.org/JDownloader.jar && \
	java -Djava.awt.headless=true -jar /opt/JDownloader/JDownloader.jar && \
	mkdir -p /tmp/ && chmod 1777 /tmp &&\
	wget -O /tmp/su-exec.tar.gz https://github.com/ncopa/su-exec/archive/v0.2.tar.gz && \
	cd /tmp/ && tar -xf su-exec.tar.gz && cd su-exec-0.2 && make && cp su-exec /usr/bin &&\
	apt-get purge -yqq wget make gcc && apt-get autoremove -yqq && cd / && rm -rf /tmp/* &&\
	rm -rf /usr/share/doc

# Beta sevenzipbindings and entrypoint
COPY common/* /opt/JDownloader/
RUN chmod +x /opt/JDownloader/entrypoint.sh

VOLUME /opt/JDownloader/cfg
VOLUME /opt/JDownloader/Downloads

ENTRYPOINT ["tini", "-g", "--", "/opt/JDownloader/entrypoint.sh"]
# Run this when the container is started
CMD ["java", "-Djava.awt.headless=true", "-jar", "/opt/JDownloader/JDownloader.jar"]
