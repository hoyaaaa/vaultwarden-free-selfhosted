# Free Self-hosted Vaultwarden Setup with Fly.io, and Google Cloud Storage

[English](docs/README.md)

---

이 가이드는 Fly.io(도커 컨테이너를 실행할 수 있는 무료 티어 서비스)와 Google Cloud Storage를 사용하여 무료로 Vaultwarden 인스턴스를 셀프 호스팅하는 방법을 안내합니다. 파일 저장과 백업을 위한 안정적인 스토리지로 Google Cloud Storage를 활용하며, 이 모든 것은 무료 티어 내에서 가능합니다.

- **Vaultwarden**: 2FA(이중 인증) 등의 기능을 무료로 지원하는 Bitwarden의 셀프 호스팅.
- **Fly.io**: 도커 컨테이너를 무료로 배포할 수 있는 서비스.
- **Google Cloud Storage** (선택사항): 안정적인 파일 저장 및 백업을 위한 용도로 사용되며, 이 또한 무료 티어로 이용 가능합니다. _Fly.io의 무료 티어가 종료될 경우에 대비하여 데이터를 백업하는 것을 추천합니다. 이 기능을 사용하지 않는 경우 Fly.io의 자체 디스크가 사용되며, 이것도 무료 티어로 사용할 수 있습니다._

## 설정 단계

⚠️ **주의 사항**: Google Cloud 설정을 건너뛰고 싶다면 [3](#3-flytoml-파일-수정)으로 이동해주세요.

### 1. Google Cloud 키 파일 생성

Google Cloud Storage에 접근하기 위해 서비스 계정 키 파일(`keyfile.json`)을 생성하는 방법은 다음과 같습니다.

#### 사전 요구 사항

- Google Cloud 프로젝트에 접근할 수 있어야 합니다.
- `gcloud` CLI가 설치되어 있어야 합니다. 설치되지 않았다면 [여기](https://cloud.google.com/sdk/docs/install)에서 설치할 수 있습니다.

#### 서비스 계정 키 파일 생성 단계

##### 1. 필수 API 활성화

서비스 계정을 생성하기 전에, Google Cloud 프로젝트에서 다음 API가 활성화되었는지 확인하세요:
- **Google Cloud Storage API**

Google Cloud Console 또는 `gcloud` 명령어로 API를 활성화할 수 있습니다:

```bash
gcloud services enable storage.googleapis.com
```

##### 2. 서비스 계정 생성

GCS 버킷에 접근하고 인증하기 위한 서비스 계정을 생성해야 합니다.

1. [Google Cloud Console](https://console.cloud.google.com/)을 엽니다.
2. **IAM & Admin** > **Service Accounts**로 이동합니다.
3. 페이지 상단의 **서비스 계정 생성**을 클릭합니다.
4. 서비스 계정 이름과 설명을 입력한 후 **생성 및 계속**을 클릭합니다.
5. **이 서비스 계정에 프로젝트 접근 권한 부여** 섹션에서 다음 역할을 선택합니다:
   - **Storage Admin** (GCS 버킷에 대한 전체 제어 권한)
6. **완료**를 클릭합니다.

##### 3. 키 파일 생성 및 다운로드

서비스 계정을 생성한 후, 아래 단계를 따라 키 파일을 생성하고 다운로드합니다:

1. **IAM & Admin** > **Service Accounts** 페이지에서 새로 생성한 서비스 계정을 찾습니다.
2. 서비스 계정 이메일을 클릭하여 세부 정보 페이지로 이동합니다.
3. **키** 탭을 선택합니다.
4. **키 추가** > **새 키 생성**을 클릭합니다.
5. 팝업 창에서 **JSON** 형식을 선택합니다.
6. **생성**을 클릭합니다. JSON 파일이 자동으로 다운로드됩니다. 이 파일은 Google Cloud 서비스에 인증할 때 사용할 자격 증명을 포함합니다.

다운로드한 파일을 프로젝트 루트에 `keyfile.json`으로 저장하세요.

### 2. Google Cloud Storage 버킷 생성

Google Cloud Storage 버킷을 생성하려면 아래 단계를 따르세요:

1. [Google Cloud Console](https://console.cloud.google.com/)을 엽니다.
2. **Cloud Storage** > **Buckets**로 이동합니다.
3. **버킷 생성**을 클릭합니다.
4. 전역에서 고유한 이름을 버킷에 지정하고 데이터를 저장할 위치를 선택합니다.
5. 기본 스토리지 클래스와 액세스 제어 옵션을 필요에 맞게 설정합니다.
6. **생성**을 클릭하여 버킷 생성 완료.

버킷이 생성되면, Vaultwarden의 백업 및 파일 저장 용도로 사용할 수 있습니다.

### 3. `fly.toml` 파일 수정

앱을 배포하고 Google Cloud Storage를 설정하려면 `fly.toml` 파일에서 두 가지 주요 수정을 해야 합니다:

1. **`APP_NAME` 업데이트**:

`fly.toml` 파일에서 `<APP_NAME>`을 Fly.io 앱의 고유한 이름으로 변경하세요. 이 이름은 전역적으로 고유해야 하며, 호스트 이름 생성에 사용됩니다.

```toml
app = "<APP_NAME>"  # 고유한 앱 이름으로 변경
```

⚠️ **주의 사항**: Google Cloud를 사용 중이라면 `2-1`로 이동하세요. 그렇지 않다면 `2-2`로 이동하세요.

2-1. **`BUCKET_NAME` 업데이트**:

Google Cloud Storage 버킷을 마운트하려면 `<BUCKET_NAME>`을 Google Cloud Storage에서 생성한 버킷 이름으로 변경하세요.

```toml
BUCKET_NAME = "<BUCKET_NAME>"  # GCloud 버킷 이름으로 변경
```

2-2. **Dockerfile 없이 도커 이미지 빌드**:

Google Cloud 대신 Fly.io의 자체 디스크를 사용하려면 아래 부분을 주석 해제하세요.

```toml
# GCP 설정을 건너뛰려면 아래를 주석 해제해주세요.
[build]
  image = "vaultwarden/server:latest"
```

### 4. Fly.io CLI 설치 및 Dockerfile 배포

Vaultwarden 설정을 Fly.io에 배포하려면 아래 단계를 따르세요:

#### 1. Fly.io CLI 설치

Linux/Mac에서 다음 명령어를 실행하여 Fly.io CLI를 설치할 수 있습니다:

```bash
curl -L https://fly.io/install.sh | sh
```

Windows 사용자는 공식 [문서](https://fly.io/docs/hands-on/install-flyctl/)를 참조하여 설치 방법을 확인하세요.

#### 2. Fly.io에 로그인

CLI를 사용해 Fly.io 계정에 로그인하세요:

```bash
flyctl auth login
```

#### 3. Fly.io 앱 초기화

프로젝트 루트 폴더로 이동한 후, Fly.io 앱을 초기화하기 위해 아래 명령어를 실행하세요:

```bash
flyctl launch
```

이 명령어는 앱 이름, 리전, 배포 여부 등 몇 가지 입력을 요청합니다. `fly.toml` 파일에서 설정한 앱 이름을 사용하고, 가까운 리전을 선택한 후 즉시 배포할지 여부를 결정하세요.

#### 4. Dockerfile 배포

앱 설정 후, 아래 명령어를 실행하여 Vaultwarden Dockerfile을 배포하세요:

```bash
flyctl deploy
```

이 명령어는 도커 컨테이너를 빌드하고 배포하여 Vaultwarden 인스턴스를 Fly.io 인프라에서 사용할 수 있게 만듭니다.

### 5. Bitwarden 설정

Vaultwarden 인스턴스를 Fly.io에 배포한 후, Fly.io가 할당한 호스트 이름을 사용하여 접근할 수 있습니다.

- 호스트 이름은 `https://<APP_NAME>.fly.dev`입니다.
- 이 URL을 방문하여 Vaultwarden 계정을 생성하세요.

Bitwarden 앱 또는 웹 인터페이스에서 설정하는 방법:
1. Bitwarden 로그인 페이지에서 `Logging in on:` 옵션을 찾습니다.
2. `Self-hosted` 옵션을 선택하세요.
3. `Server URL` 필드에 Vaultwarden을 배포한 URL (`https://<APP_NAME>.fly.dev`)을 입력합니다.
4. Vaultwarden 서버에서 생성한 사용자 이름과 비밀번호로 로그인하세요.

### 추가 정보

- `keyfile.json`이 Google Cloud Storage에 접근할 수 있도록 `Dockerfile` 또는 `startup.sh` 스크립트에서 올바르게 참조되는지 확인하세요.
- Fly.io 및 Google Cloud의 사용량을 모니터링하여 무료 티어 한도를 초과하지 않도록 주의하세요.
- 백업 및 보안 강화는 필요에 따라 추가로 설정할 수 있습니다.

문제가 발생할 경우, [Vaultwarden](https://github.com/dani-garcia/vaultwarden), [Fly.io](https://fly.io/docs/), [Google Cloud](https://cloud.google.com/)의 공식 문서를 참조하세요.

## 기여하기

이 프로젝트에 기여하고 싶다면 아래 가이드를 따르세요:

1. 리포지토리를 포크합니다.
2. 기능 브랜치를 생성합니다.
3. 변경 사항을 적용합니다.
4. **main 브랜치**로 Pull Request(PR)를 제출합니다.
