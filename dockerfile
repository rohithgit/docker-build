#docker build -t devops-training .
FROM docker:dind

WORKDIR /root/
#Update all lib
RUN  apk update \
  && apk upgrade \
  && apk add ca-certificates \
  && update-ca-certificates \
  && apk add --update coreutils && rm -rf /var/cache/apk/* \
  && apk add --no-cache nss \
  && rm -rf /var/cache/apk/*


##Install Python3.7.12
ENV PATH /usr/local/bin:$PATH
# runtime dependencies
RUN set -eux; \
	apk add --no-cache \
# install ca-certificates so that HTTPS works consistently
		ca-certificates \
	;


# Install system dependencies
RUN apk add --no-cache python3 py3-pip
# Set up a virtual environment
RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
# Set the virtual environment as the default Python environment
ENV PATH="/opt/venv/bin:$PATH"


# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config \
	&& cd /
##End of Python3.7.12 Installations


## Install dependencies to build projects
RUN apk add --update --no-cache \
    gcc glib make libffi-dev musl-dev openssl-dev python3-dev \
    openjdk8-jre ca-certificates zip curl jq git py3-wheel \
    tzdata curl unzip zip bash wget sudo nodejs gzip grep icu-libs krb5-libs libgcc libintl libssl1.1 libstdc++ zlib \
    && rm -rf /var/cache/apk/*


#Setup JAVA_HOME PATH
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk
ENV PATH $PATH:$JAVA_HOME/bin


#Isntall Azure
RUN \
  apk update && \
  apk add py-pip && \
  apk add --virtual=build && \
  pip --no-cache-dir install -U pip && \
  pip install azure-cli && \
  apk del --purge build

#Install helm and Kubectl
RUN curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x ./kubectl \
    && mv ./kubectl /usr/local/bin/kubectl \
    && curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
    && chmod +x get_helm.sh && ./get_helm.sh

ENV PATH $PATH:/usr/bin
#Install .net
RUN wget https://dot.net/v1/dotnet-install.sh -O $HOME/dotnet-install.sh && \
    chmod +x $HOME/dotnet-install.sh && \
    $HOME/dotnet-install.sh -c 5.0 && \
    apk add libgdiplus --repository https://dl-3.alpinelinux.org/alpine/edge/testing/ && \
    export PATH="$PATH:/root/.dotnet"

RUN java -version && \
    helm version  && \
    az --version && \
    python --version && \
    echo "$PATH"

CMD []
