# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

  HTTPSでローカル開発を行うために、自己署名証明書('.certificate'ディレクトリ)をマウントしています。
  `.env` ファイルに以下の設定を追加してください。
  ```
  SSL_PORT=3443
  SSL_KEY_PATH=/rails/certs/localhost-key.pem
  SSL_CERT_PATH=/rails/certs/localhost-cert.pem
  ```
  アクセス先:
  * HTTPS: `https://localhost:8443`
  * HTTP: `http://localhost:8080`

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
