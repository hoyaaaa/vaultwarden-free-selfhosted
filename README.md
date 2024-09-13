# Free Self-hosted Vaultwarden Setup with Fly.io, and Google Cloud Storage

[한국어](docs/README.ko.md)

---

This guide will help you set up a free self-hosted Vaultwarden instance using Fly.io (a free-tier service to run Docker containers), and Google Cloud Storage for stable file storage and backups. You can fully utilize these services within their free tiers.

- **Vaultwarden**: A self-hosted implementation of Bitwarden, supporting features like 2FA (Two-Factor Authentication) for free.
- **Fly.io**: A service that allows you to deploy Docker containers for free.
- **Google Cloud Storage** (Optional): Used for more stable file storage and backups, which can also be utilized within the free tier. _In case Fly.io’s free tier comes to an end, I recommend using this to back up your data. If you don’t use this feature, Fly.io’s own disk will be used, which is also available under the free tier._

## Steps to Set Up

⚠️ Note: If you want to skip the Google Cloud setup, please proceed to [3](#3-edit-flytoml-file).

### 1. Generate a Google Cloud Keyfile

Follow these steps to generate a service account keyfile (`keyfile.json`), which will be used to access Google Cloud Storage.

#### Prerequisites

- You must have access to a Google Cloud project.
- You must have `gcloud` CLI installed. If not, you can install it from [here](https://cloud.google.com/sdk/docs/install).

#### Steps to Generate a Service Account Keyfile

##### 1. Enable Required APIs

Before creating the service account, ensure that you have enabled the following APIs for your Google Cloud project:
- **Google Cloud Storage API**

You can enable them through the Google Cloud Console or via `gcloud`:

```bash
gcloud services enable storage.googleapis.com
```

##### 2. Create a Service Account

You need to create a service account that will be used to authenticate and access the GCS bucket.

1. Open the [Google Cloud Console](https://console.cloud.google.com/).
2. Navigate to **IAM & Admin** > **Service Accounts**.
3. Click **Create Service Account** at the top of the page.
4. Enter the service account name and description, then click **Create and Continue**.
5. In the **Grant this service account access to the project** section, select the following roles:
   - **Storage Admin** (for full control over GCS buckets)
6. Click **Done**.

##### 3. Create and Download the Keyfile

Once the service account is created, follow these steps to create and download the keyfile:

1. In the **IAM & Admin** > **Service Accounts** page, find your newly created service account.
2. Click on the service account's email to go to its details page.
3. Select the **Keys** tab.
4. Click **Add Key** > **Create New Key**.
5. In the pop-up window, select **JSON** as the key type.
6. Click **Create**. A JSON file will be downloaded automatically. This file contains the credentials that will be used to authenticate with Google Cloud services.

After downloading, save this file as `keyfile.json` in the root of your project.

### 2. Create a Google Cloud Storage bucket

To create a Google Cloud Storage bucket, follow these steps:

1. Open the [Google Cloud Console](https://console.cloud.google.com/).
2. Navigate to **Cloud Storage** > **Buckets**.
3. Click **Create Bucket**.
4. Choose a globally unique name for your bucket and select the location where you want to store your data.
5. Set the default storage class and access control options based on your needs.
6. Click **Create** to finalize the bucket creation.

Once the bucket is created, you can use it to store backups and files for Vaultwarden.

### 3. Edit `fly.toml` File

To deploy your app and configure Google Cloud Storage, you need to make two key modifications in the `fly.toml` file:

1. **Update `APP_NAME`**:

In the `fly.toml` file, replace `<APP_NAME>` with a unique name for your Fly.io app. This name must be globally unique and will be used to generate your hostname.

```toml
app = "<APP_NAME>"  # Replace with your unique app name
```

⚠️ Note: If you’re using Google Cloud, proceed to `2-1`. If not, proceed to `2-2`.

2-1. **Update `BUCKET_NAME`**:

To mount the Google Cloud Storage bucket, replace `<BUCKET_NAME>` with the name of the bucket you created in Google Cloud Storage.

```toml
BUCKET_NAME = "<BUCKET_NAME>"  # Replace with your GCloud bucket name
```

2-2. **Build docker image without Dockerfile**

To use Fly.io’s own disk instead of Google Cloud, please uncomment the section below.

```toml
# To skip the GCP setup, please uncomment the section below.
[build]
  image = "vaultwarden/server:latest"
```

### 4. Install Fly.io CLI and Deploy the Dockerfile

To deploy your Vaultwarden setup on Fly.io, follow these steps:

#### 1. Install Fly.io CLI

You can install Fly.io's CLI by running the following command (on Linux/Mac):

```bash
curl -L https://fly.io/install.sh | sh
```

For Windows, follow the instructions in their official [documentation](https://fly.io/docs/hands-on/install-flyctl/).

#### 2. Login to Fly.io

Login to your Fly.io account using the CLI:

```bash
flyctl auth login
```

#### 3. Initialize the Fly.io App

Navigate to the project root folder and run the following command to initialize the Fly.io app:

```bash
flyctl launch
```

This command will ask for some inputs, such as your app name, region, and whether to deploy. Use the app name you set in the `fly.toml` file, select a nearby region, and choose whether to deploy immediately or later.

#### 4. Deploy the Dockerfile

After setting up your app, deploy your Vaultwarden Dockerfile by running the following command:

```bash
flyctl deploy
```

This will build and deploy your Docker container, making your Vaultwarden instance available on the Fly.io infrastructure.

### 5. Set Up Bitwarden

Once you deploy your Vaultwarden instance on Fly.io, you can access it using the hostname assigned by Fly.io.

- The hostname will be `https://<APP_NAME>.fly.dev`.
- Visit this URL and create an account in Vaultwarden.

To set this up in the Bitwarden app or web interface:
1. On the Bitwarden login page, find the `Logging in on:` option.
2. Choose the `Self-hosted` option.
3. In the `Server URL` field, enter the URL of your deployed Vaultwarden (`https://<APP_NAME>.fly.dev`).
4. Log in using the username and password you created on the Vaultwarden server.

### Additional Notes

- Make sure the `keyfile.json` is correctly referenced in your `Dockerfile` or `startup.sh` script to allow access to Google Cloud Storage.
- Monitor the usage of both Fly.io and Google Cloud to ensure you stay within the free tier limits.
- Optionally, you can configure backups and further security enhancements based on your needs.

For any issues, please consult the official documentation for [Vaultwarden](https://github.com/dani-garcia/vaultwarden), [Fly.io](https://fly.io/docs/), and [Google Cloud](https://cloud.google.com/).

## Contribute

If you would like to contribute to this project, please follow the guidelines below:

1. Fork the repository.
2. Create a feature branch.
3. Make your changes.
4. Submit a Pull Request (PR) to the **main branch**.