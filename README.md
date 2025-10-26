# rails-auth-api-sample

## 環境構築

1. **ディレクトリ作成**

   ```bash
   mkdir -p apps/api
   ```

2. **Dockerfileとdocker-compose.ymlの作成**

   `apps/api/Dockerfile` と `docker-compose.yml` を作成します。（内容は省略）

3. **Railsプロジェクトの雛形作成**

   コンテナのビルドと`rails new`を一度に実行しようとすると依存関係で問題が発生するため、以下の手順で実行します。

   ```bash
   # 1. Railsのgemを含む最小限のGemfileを作成
   echo 'source "https://rubygems.org"' > apps/api/Gemfile
   echo 'gem "rails", "~> 7.1"' >> apps/api/Gemfile

   # 2. Gemfile.lockを生成
   docker run --rm -v "$(pwd)/apps/api:/app" -w /app ruby:3.2.2 bundle install

   # 3. Railsプロジェクトを作成
   docker-compose run --build --rm api rails new . --force --database=mysql --api
   ```

4. **ファイル所有権の変更**

   `rails new`で生成されたファイルの所有者が`root`になるため、ホストのユーザーに変更します。

   ```bash
   # このコマンドはホストのターミナルで実行する必要がある
   sudo chown -R $(whoami) apps/api
   ```

5. **コンテナの起動とデータベースのセットアップ**

   ```bash
   # コンテナをバックグラウンドで起動
   docker-compose up --build -d

   # データベースを作成
   docker-compose exec api bin/rails db:create
   ```

6. **Userモデルの作成**

   ```bash
   # rootユーザーで`generate`コマンドを実行
   docker-compose exec --user root api bin/rails generate model User uuid:string:uniq name:string email:string:uniq password_digest:string

   # 再度、ファイルの所有権を変更
   sudo chown -R $(whoami) apps/api

   # データベースマイグレーションを実行
   docker-compose exec api bin/rails db:migrate
   ```

7. **bcryptのインストールと設定**

   ```bash
   # Gemfileにbcryptを追加
   echo 'gem "bcrypt", "~> 3.1.7"' >> apps/api/Gemfile

   # gemをインストール
   docker-compose exec api bundle install
   ```
   その後、`app/models/user.rb` に `has_secure_password` を追記しました。
