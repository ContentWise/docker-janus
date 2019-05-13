FROM maven:3-jdk-8 as builder

# Build custom serializer
COPY janus-serializer /usr/src/janus-serializer
WORKDIR /usr/src/janus-serializer
RUN mvn clean package

# Build DynamoDB storage backend plugin
ARG DYNAMODB_PLUGIN_VERSION=jg0.2.0-1.2.0
RUN git clone https://github.com/awslabs/dynamodb-janusgraph-storage-backend /usr/src/dynamodb-janusgraph-storage-backend
WORKDIR /usr/src/dynamodb-janusgraph-storage-backend
RUN git checkout ${DYNAMODB_PLUGIN_VERSION}
RUN MAVEN_OPTS="-XX:+TieredCompilation -XX:TieredStopAtLevel=1" mvn -T 1C clean package -Dmaven.test.skip=true -DskipTests=true

# Build janus image
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
RUN mkdir -p /opt/janus/ext/janus-serializer /opt/janus/ext/dynamodb-janusgraph-storage-backend
COPY --from=builder /usr/src/janus-serializer/target/janus-serializer.jar /opt/janus/ext/janus-serializer.jar
COPY --from=builder \
    /usr/src/dynamodb-janusgraph-storage-backend/target/dynamodb-janusgraph-storage-backend-1.2.0.jar \
    /usr/src/dynamodb-janusgraph-storage-backend/target/dependencies \
    /opt/janus/ext/dynamodb-janusgraph-storage-backend/
RUN mkdir -p /opt/janus/badlibs && \
    cd /opt/janus/lib && \
    mv joda-time-2.8.2.jar slf4j-log4j12-1.7.12.jar logback-classic-1.1.2.jar ../badlibs
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh
COPY templates /templates

RUN chown -R user:group /opt/janus
USER user
ENTRYPOINT [ "/docker-entrypoint.sh" ]
WORKDIR /opt/janus
CMD [ "./bin/gremlin-server.sh", "./conf/gremlin-server/gremlin-server.yaml" ]