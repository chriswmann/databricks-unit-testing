FROM ubuntu:20.04 as base

ENV TZ=Europe/London
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get update && \
    apt-get install -y --no-install-recommends openjdk-11-jre-headless \
        wget vim software-properties-common python3.9 python3-pip \
        curl unzip libpq-dev build-essential libssl-dev libffi-dev \
        pypy-dev python3.9-dev && \
    apt-get clean

RUN wget https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3.tgz && \
    tar xvf spark-3.5.1-bin-hadoop3.tgz && \
    mv spark-3.5.1-bin-hadoop3/ /usr/local/spark && \
    ln -s /usr/local/spark spark && \
    wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.890/aws-java-sdk-bundle-1.11.890.jar && \
    mv aws-java-sdk-bundle-1.11.890.jar /spark/jars && \
    wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.4.0/hadoop-aws-3.4.0.jar && \
    mv hadoop-aws-3.4.0.jar /spark/jars

WORKDIR app
COPY . /app

RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 2
RUN update-alternatives --config python3
RUN pip3 install --upgrade pip
RUN pip3 install -r requirements.txt

FROM base as final

ENV PYSPARK_PYTHON=python3
ENV PYSPARK_SUBMIT_ARGS='--packages io.delta:delta-core_2.12:2.1.0 pyspark-shell'
