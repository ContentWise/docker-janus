FROM maven:3-jdk-8 as builder
COPY janus-serializer /usr/src/janus-serializer
WORKDIR /usr/src/janus-serializer
RUN mvn clean package

FROM contentwisetv/openjdk-waitforit-goreplay:jre8
USER root
ARG DOCKERIZE_VERSION=v0.6.1
ARG JANUS_VERSION=0.2.0
ARG JANUS_VERSION_SUFFIX=hadoop2
RUN apk add --no-cache bash perl
RUN wget -O /tmp/janus.zip "https://github.com/JanusGraph/janusgraph/releases/download/v${JANUS_VERSION}/janusgraph-${JANUS_VERSION}-${JANUS_VERSION_SUFFIX}.zip" && \
    unzip /tmp/janus.zip -d /tmp/ && \
    mv "/tmp/janusgraph-${JANUS_VERSION}-${JANUS_VERSION_SUFFIX}" /opt/janus && \
    rm /tmp/janus.zip && \
    wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz
COPY --from=builder /usr/src/janus-serializer/target/janus-serializer.jar /opt/janus/lib/janus-serializer.jar
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
COPY templates /templates

RUN chown -R user:group /opt/janus
USER user
ENTRYPOINT [ "/docker-entrypoint.sh" ]
CMD [ "/opt/janus/bin/gremlin-server.sh", "/opt/janus/conf/gremlin-server/gremlin-server.yaml" ]