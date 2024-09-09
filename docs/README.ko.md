# Free Self-hosted Vaultwarden Setup with Fly.io, and Google Cloud Storage

이 가이드는 Fly.io(도커 컨테이너를 실행할 수 있는 무료 서비스)와 Google Cloud Storage(안정적인 파일 저장 및 백업을 위한 서비스)를 사용하여 무료로 Vaultwarden 셀프 호스팅 인스턴스를 설정하는 방법을 설명합니다. 이 서비스들은 모두 무료 요금제로 충분히 활용 가능합니다.

- **Vaultwarden**: 무료로 2FA(이중 인증)와 같은 기능을 지원하는 Bitwarden의 셀프 호스팅 구현입니다.
- **Fly.io**: 도커 컨테이너를 무료로 배포할 수 있는 서비스입니다.
- **Google Cloud Storage**: 안정적인 파일 저장 및 백업을 제공하며, 무료 요금제로 충분히 사용할 수 있습니다.

## 설정 단계

### 1. Google Cloud Keyfile 생성

Google Cloud Storage에 접근하기 위해 사용할 서비스 계정 키파일(`keyfile.json`)을 생성하는 방법은 다음과 같습니다.

#### 전제 조건

- Google Cloud 프로젝트에 대한 접근 권한이 있어야 합니다.
- `gcloud` CLI가 설치되어 있어야 합니다. 설치되지 않았다면 [여기](https://cloud.google.com/sdk/docs/install)에서 설치할 수 있습니다.

#### 서비스 계정 키파일 생성 단계

##### 1. 필요한 API 활성화

서비스 계정을 만들기 전에 Google Cloud 프로젝트에서 다음 API가 활성화되어 있는지 확인합니다:
- **Google Cloud Storage API**

Google Cloud 콘솔 또는 `gcloud`를 통해 API를 활성화할 수 있습니다:

```bash
gcloud services enable storage.googleapis.com
```

##### 2. 서비스 계정 생성

GCS 버킷에 인증 및 접근을 위해 사용할 서비스 계정을 생성해야 합니다.

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속합니다.
2. **IAM & Admin** > **Service Accounts**로 이동합니다.
3. 페이지 상단의 **Create Service Account** 버튼을 클릭합니다.
4. 서비스 계정 이름과 설명을 입력한 후, **Create and Continue**를 클릭합니다.
5. **Grant this service account access to the project** 섹션에서 다음 역할을 선택합니다:
   - **Storage Admin** (GCS 버킷에 대한 전체 권한)
6. **Done**을 클릭합니다.

##### 3. 키파일 생성 및 다운로드

서비스 계정을 생성한 후, 다음 단계를 따라 키파일을 생성하고 다운로드합니다:

1. **IAM & Admin** > **Service Accounts** 페이지에서 새로 생성한 서비스 계정을 찾습니다.
2. 해당 서비스 계정 이메일을 클릭하여 세부 정보 페이지로 이동합니다.
3. **Keys** 탭을 선택합니다.
4. **Add Key** > **Create New Key**를 클릭합니다.
5. 팝업 창에서 **JSON**을 키 유형으로 선택합니다.
6. **Create**를 클릭하면 JSON 파일이 자동으로 다운로드됩니다. 이 파일에는 Google Cloud 서비스에 인증할 수 있는 자격 증명이 포함되어 있습니다.

다운로드한 후, 이 파일을 프로젝트 루트에 `keyfile.json`으로 저장합니다.

### 2. Google Cloud Storage 버킷 생성

Google Cloud Storage 버킷을 생성하려면 다음 단계를 따릅니다:

1. [Google Cloud Console](https://console.cloud.google.com/)에 접속합니다.
2. **Cloud Storage** > **Buckets**로 이동합니다.
3. **Create Bucket**을 클릭합니다.
4. 버킷에 사용할 전 세계적으로 고유한 이름을 입력하고 데이터를 저장할 위치를 선택합니다.
5. 기본 저장소 클래스와 액세스 제어 옵션을 필요에 맞게 설정합니다.
6. **Create**를 클릭하여 버킷 생성을 완료합니다.

버킷이 생성되면 Vaultwarden의 백업 및 파일 저장에 사용할 수 있습니다.

### 3. `fly.toml` 파일 수정

앱을 배포하고 Google Cloud Storage를 구성하려면 `fly.toml` 파일에서 두 가지 주요 수정을 해야 합니다:

1. **`APP_NAME` 업데이트**:

`fly.toml` 파일에서 `<APP_NAME>`을 Fly.io 앱의 고유한 이름으로 교체합니다. 이 이름은 전 세계적으로 고유해야 하며, 호스트 이름 생성에 사용됩니다.

```toml
app = "<APP_NAME>"  # 고유한 앱 이름으로 교체
```

2. **`BUCKET_NAME` 업데이트**:

Google Cloud Storage 버킷을 마운트하려면 `<BUCKET_NAME>`을 Google Cloud Storage에서 생성한 버킷 이름으로 교체합니다.

```toml
BUCKET_NAME = "<BUCKET_NAME>"  # GCloud 버킷 이름으로 교체
```

`APP_NAME`과 `BUCKET_NAME` 모두 배포를 진행하기 전에 올바르게 설정되었는지 확인하십시오.

### 4. Fly.io CLI 설치 및 Dockerfile 배포

Vaultwarden 설정을 Fly.io에 배포하려면 다음 단계를 따르십시오:

#### 1. Fly.io CLI 설치

Linux/Mac에서 Fly.io의 CLI를 설치하려면 다음 명령어를 실행합니다:

```bash
curl -L https://fly.io/install.sh | sh
```

Windows의 경우, 공식 [문서](https://fly.io/docs/hands-on/install-flyctl/)를 참조하십시오.

#### 2. Fly.io 로그인

CLI를 사용하여 Fly.io 계정에 로그인합니다:

```bash
flyctl auth login
```

#### 3. Fly.io 앱 초기화

프로젝트 루트 폴더로 이동하여 Fly.io 앱을 초기화하려면 다음 명령어를 실행합니다:

```bash
flyctl launch
```

이 명령어는 앱 이름, 지역, 배포 여부 등의 입력을 요청합니다. `fly.toml` 파일에 설정한 앱 이름을 사용하고, 가까운 지역을 선택하며 즉시 배포할지 나중에 배포할지 선택합니다.

#### 4. Dockerfile 배포

앱 설정을 완료한 후 다음 명령어를 실행하여 Vaultwarden Dockerfile을 배포합니다:

```bash
flyctl deploy
```

이 명령어는 도커 컨테이너를 빌드하고 Fly.io 인프라에 Vaultwarden 인스턴스를 배포합니다.

### 5. Bitwarden 설정

Fly.io에서 Vaultwarden 인스턴스를 배포한 후, Fly.io에서 할당한 호스트 이름을 사용하여 Vaultwarden에 접속할 수 있습니다.

- 호스트 이름은 `https://<APP_NAME>.fly.dev`입니다.
- 이 URL에 접속하여 Vaultwarden 계정을 생성합니다.

Bitwarden 앱 또는 웹 인터페이스에서 다음과 같이 설정합니다:
1. Bitwarden 로그인 페이지에서 `Logging in on:` 옵션을 찾습니다.
2. `Self-hosted` 옵션을 선택합니다.
3. `Server URL` 필드에 배포된 Vaultwarden의 URL(`https://<APP_NAME>.fly.dev`)을 입력합니다.
4. Vaultwarden 서버에서 생성한 아이디와 비밀번호로 로그인합니다.

### 추가 참고 사항

- Google Cloud Storage에 접근할 수 있도록 `keyfile.json`이 `Dockerfile` 또는 `startup.sh` 스크립트에서 올바르게 참조되고 있는지 확인하십시오.
- Fly.io와 Google Cloud의 사용량을 모니터링하여 무료 요금제 내에서 유지되도록 하십시오.
- 백업 및 추가 보안 강화 구성을 필요에 따라 설정할 수 있습니다.

문제가 있을 경우, [Vaultwarden](https://github.com/dani-garcia/vaultwarden), [Fly.io](https://fly.io/docs/), 그리고 [Google Cloud](https://cloud.google.com/)의 공식 문서를 참조하십시오.

## 기여

이 프로젝트에 기여하고 싶다면, 아래의 지침을 따라주세요:

1. 저장소를 포크하세요.
2. 기능 브랜치를 생성하세요.
3. 변경 사항을 반영하세요.
4. **main 브랜치**로 Pull Request(PR)를 제출하세요.
