# rails-auth-api-sample 作成計画

## はじめに 
- Ruby, Ruby on Rails未経験者が、慣れるためにハンズオン的にサンプルアプリとして認証APIを作りたい。
- オーナーは、他の言語での実務での実装経験あり

## 設計

ディレクトリ構成

- docs/ （openapi.yamlを置く）
- apps/api/ （バックエンド ここにRailsのコードを置く）
- apps/web/ （フロントエンド TBD）

エンドポイントは、以下の通り。

- `POST /api/auth/signup` - ユーザー登録（ユーザー名、メールアドレス、パスワードを登録する）
    - リクエストボディ
        - name
        - email
        - password
    - レスポンスボディ
        - uuid
        - name
        - email
- `POST /api/auth/login` - ログイン（メールアドレス、パスワードでログインする）
    - リクエストボディ
        - email
        - password
    - レスポンスボディ
        - uuid
        - access_token
        - refresh_token
- `POST /api/auth/refresh` - トークン更新（リフレッシュトークンでアクセストークンを更新する）
    - リクエストボディ
        - refresh_token
    - レスポンスボディ
        - access_token
        - refresh_token
- `POST /api/auth/logout` - ログアウト（アクセストークンを無効化する）
- `GET /api/auth/me` - 現在のユーザー情報取得（アクセストークンからユーザー情報を取得する）
    - レスポンスボディ
        - uuid
        - name
        - email

Userテーブルのスキーマは以下の通り。

```sql
CREATE TABLE "users" (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    uuid CHAR(36) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```
他には、

- Docker
- MySQL（永続化）
- Redis（リフレッシュトークン保持）
- Swagger, Openapi
- JWT（認証用トークン）

## アーキテクチャ
バックエンドAPIはDDD的なクリーンアーキテクチャにしたいところですが、Railsはあまり相性が良くないと聞きました。ケーススタディなので、Railsのベストプラクティス的な構成にしてください。

## 進め方など

- パッケージのインストールコマンドなどの履歴はREADME.mdに残したい。
- DockerのコマンドなどはMakefileに記述し、`make init`でコンテナをbuildできるようにする。
- テストコードも追加したい。
- もし入れるべきVSCodeの機能拡張があれば`.vcscode`以下にsettings.jsonを作成して指示してください。
