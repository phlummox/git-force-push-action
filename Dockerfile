
FROM alpine:3.12.0@sha256:a15790640a6690aa1730c38cf0a440e2aa44aaca9b0e8931a9f2b0d7cc90fd65

RUN apk --no-cache add \
      bash \
      git \
      openssh-client \
  && \
  echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

LABEL "com.github.actions.description"="force-push commits in one branch, to a branch in another repo"
LABEL "com.github.actions.color"="green"
LABEL "repository"="https://github.com/phlummox/git-force-push-action"

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
