# Rails 認証API サンプル

Ruby on Railsを使用してトークンベースの認証APIを構築する方法を示すサンプルプロジェクトです。

## 機能

- **ユーザー認証:**
  - ユーザー登録 (`/api/auth/signup`)
  - メールアドレスとパスワードでのログイン (`/api/auth/login`)
  - JWTベースのアクセストークン発行
- **トークン管理:**
  - リフレッシュトークンの発行とローテーション (`/api/auth/refresh`)
  - ログアウト（リフレッシュトークンの無効化） (`/api/auth/logout`)
- **ユーザー情報:**
  - 有効なトークンから現在のユーザー情報を取得 (`/api/auth/me`)
- **コンテナ化された開発環境:**
  - DockerとDocker Composeを使用した完全なコンテナ開発環境
  - 一般的なコマンドに簡単にアクセスするためのMakefile
- **APIドキュメント:**
  - Swagger UIで提供されるOpenAPI仕様

## 技術スタック

- **バックエンド:** Ruby on Rails 7
- **データベース:** MySQL 8
- **インメモリストア:** Redis 7 (リフレッシュトークン用)
- **コンテナ化:** Docker, Docker Compose
- **API仕様:** OpenAPI 3.0 (Swagger)

## 前提条件

- Docker
- Docker Compose
- mkcert (ローカルHTTPS用、任意ですが推奨)

## 開発用SSL証明書の準備

HTTPSでローカル開発を行う場合、自己署名証明書が必要です。

まだローカル認証局を作成していない場合
```bash
mkcert -install
```

.certificate ディレクトリに `localhost-cert.pem` と `localhost-key.pem` を配置してください。
```bash
mkdir -p .certificate
mkcert -key-file .certificate/localhost-key.pem -cert-file .certificate/localhost-cert.pem localhost 127.0.0.1 ::1
```

## 🚀 セットアップと使い方

1.  **リポジトリをクローン**

2.  **`.env`ファイルの作成:**
    サンプルファイルをコピーして、必要な環境変数を設定します。
    ```bash
    cp .env.example .env
    ```
    *（ローカル開発では、デフォルト値のままで動作します。）*

3.  **アプリケーションの起動:**
    このコマンドはDockerイメージをビルドし、`api`, `db`, `redis`, `swagger-ui`の各コンテナをバックグラウンドで起動します。
    ```bash
    make up
    ```

4.  **データベースの準備:**
    初回起動時には、データベースの作成とマイグレーションを実行する必要があります。
    ```bash
    make exec CMD="bin/rails db:create"
    make exec CMD="bin/rails db:migrate"
    ```

5.  **アプリケーションが起動しました！**
    - APIは `https://localhost:8443` (HTTPS) および `http://localhost:8080` (HTTP) で利用可能です。
    - データベースはポート `3306` でアクセス可能です。
    - Redisはポート `6379` でアクセス可能です。

## 📖 APIドキュメント

APIドキュメントは`swagger-ui`コンテナによって提供されます。ブラウザで以下のURLにアクセスしてください。

- **[http://localhost:8081](http://localhost:8081)**

OpenAPIの仕様ファイルは`docs/openapi.yaml`にあります。

## ✅ テストの実行

- **すべてのテストを実行:**
  ```bash
  make test
  ```

- **特定のテストファイルを実行:**
  ```bash
  make test file=test/controllers/api/auth/sessions_controller_test.rb
  ```

## Makefile コマンド一覧

便利な`Makefile`が用意されています。

- `make up`: 必要に応じてイメージをビルドし、すべてのコンテナをデタッチモードで起動します。
- `make down`: すべてのコンテナを停止・削除します。
- `make logs`: `api`コンテナのログを追跡表示します。
- `make ps`: 実行中のすべてのコンテナの状態を表示します。
- `make exec`: `api`コンテナ内でbashシェルを起動します。
- `make test`: Minitestスイートを実行します。

---

# Rails Auth API Sample

This is a sample project to demonstrate how to build a token-based authentication API using Ruby on Rails.

## Features

- **User Authentication:**
  - User registration (`/api/auth/signup`)
  - Login with email and password (`/api/auth/login`)
  - JWT-based access token issuance
- **Token Management:**
  - Refresh token issuance and rotation (`/api/auth/refresh`)
  - Logout (refresh token invalidation) (`/api/auth/logout`)
- **User Information:**
  - Get current user information from a valid token (`/api/auth/me`)
- **Containerized Development:**
  - Fully containerized development environment using Docker and Docker Compose.
  - Makefile for easy access to common commands.
- **API Documentation:**
  - OpenAPI specification served with Swagger UI.

## Tech Stack

- **Backend:** Ruby on Rails 7
- **Database:** MySQL 8
- **In-memory Store:** Redis 7 (for refresh tokens)
- **Containerization:** Docker, Docker Compose
- **API Specification:** OpenAPI 3.0 (Swagger)

## Prerequisites

- Docker
- Docker Compose
- mkcert (for local HTTPS, optional but recommended)

## Development SSL Certificate Preparation

When developing locally with HTTPS, a self-signed certificate is required.

If you haven't created a local certificate authority yet:
```bash
mkcert -install
```

Place `localhost-cert.pem` and `localhost-key.pem` in the `.certificate` directory:
```bash
mkdir -p .certificate
mkcert -key-file .certificate/localhost-key.pem -cert-file .certificate/localhost-cert.pem localhost 127.0.0.1 ::1
```

## 🚀 Setup & Usage

1.  **Clone the repository**

2.  **Create `.env` file:**
    Copy the example file and set the required environment variables.
    ```bash
    cp .env.example .env
    ```
    *(You can leave the default values for local development.)*

3.  **Start the application:**
    This command will build the Docker images and start the `api`, `db`, `redis`, and `swagger-ui` containers in the background.
    ```bash
    make up
    ```

4.  **Prepare the database:**
    The first time you start the application, you need to create and migrate the database.
    ```bash
    make exec CMD="bin/rails db:create"
    make exec CMD="bin/rails db:migrate"
    ```

5.  **The application is now running!**
    - The API is available at `https://localhost:8443` (HTTPS) and `http://localhost:8080` (HTTP)
    - The database is accessible on port `3306`
    - Redis is accessible on port `6379`

## 📖 API Documentation

The API documentation is served by the `swagger-ui` container. You can access it in your browser at:

- **[http://localhost:8081](http://localhost:8081)**

The OpenAPI specification file is located at `docs/openapi.yaml`.

## ✅ Running Tests

- **Run all tests:**
  ```bash
  make test
  ```

- **Run a specific test file:**
  ```bash
  make test file=test/controllers/api/auth/sessions_controller_test.rb
  ```

## Makefile Commands

A `Makefile` is provided for convenience.

- `make up`: Builds images if necessary and starts all containers in detached mode.
- `make down`: Stops and removes all containers.
- `make logs`: Tails the logs of the `api` container.
- `make ps`: Shows the status of all running containers.
- `make exec`: Opens a bash shell inside the `api` container.
- `make test`: Runs the Minitest suite.
