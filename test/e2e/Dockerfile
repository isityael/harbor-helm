FROM alpine:3@sha256:5b10f432ef3da1b8d4c7eb6c487f2f5a8f096bc91145e68878dd4a5019afde11

ARG KUBECTL_VERSION="v1.27.1"
ARG HELM_VERSION="v4.2.0"
RUN apk add bash bind-tools \
    aws-cli \
    && wget https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl -P /usr/local/bin/ && chmod +x /usr/local/bin/kubectl \
    && wget -O - https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -xzO linux-amd64/helm > /usr/local/bin/helm && chmod +x /usr/local/bin/helm
