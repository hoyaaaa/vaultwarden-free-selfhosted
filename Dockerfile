FROM vaultwarden/server:latest

# Update necessary packages and install required packages for gcloud installation
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    gnupg \
    curl \
    lsb-release

# Install Google Cloud SDK
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add - && \
    apt-get update && apt-get install -y google-cloud-sdk

# Install gcsfuse
RUN export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | tee /usr/share/keyrings/cloud.google.asc && \
    apt-get update && apt-get install -y gcsfuse

# Set environment variables
ENV GOOGLE_APPLICATION_CREDENTIALS="/root/.gcloud/keyfile.json"

# gcloud authentication and bucket mount script
COPY startup.sh /usr/local/bin/startup.sh
RUN mkdir -p /root/.gcloud
COPY keyfile.json /root/.gcloud/keyfile.json
RUN chmod +x /usr/local/bin/startup.sh

# Command to execute
ENTRYPOINT ["/usr/local/bin/startup.sh"]
CMD ["/start.sh"]