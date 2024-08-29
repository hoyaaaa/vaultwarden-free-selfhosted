FROM vaultwarden/server:latest

# gcloud 설치에 필요한 패키지 업데이트 및 필수 패키지 설치
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    lsb-release

# Google Cloud SDK 설치
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install -y google-cloud-sdk

# gcsfuse 설치
# RUN export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
#    echo "deb https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
#    apt-get update && apt-get install -y gcsfuse
RUN export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.asc && \
    apt-get update && apt-get install -y gcsfuse

# 환경 변수 설정
ENV GOOGLE_APPLICATION_CREDENTIALS="/root/.gcloud/keyfile.json"

# gcloud 인증 및 버킷 마운트 스크립트
COPY startup.sh /usr/local/bin/startup.sh
RUN mkdir -p /root/.gcloud
COPY keyfile.json /root/.gcloud/keyfile.json
RUN chmod +x /usr/local/bin/startup.sh

# 실행할 명령어
ENTRYPOINT ["/usr/local/bin/startup.sh"]
CMD ["/start.sh"]
