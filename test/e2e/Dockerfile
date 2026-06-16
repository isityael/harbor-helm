FROM alpine:3@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b

ARG KUBECTL_VERSION="v1.36.1"
ARG HELM_VERSION="v4.2.0"
RUN apk add bash bind-tools \
    aws-cli \
    && wget https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -P /usr/local/bin/ && chmod +x /usr/local/bin/kubectl \
    && wget -O - https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /usr/local/bin/helm && chmod +x /usr/local/bin/helm
