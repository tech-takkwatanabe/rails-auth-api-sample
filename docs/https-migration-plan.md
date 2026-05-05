# HTTPS化 改修計画

## 背景・目的

現在、`make up` を実行すると `http://localhost:8080` でRails APIが起動するが、
HTTPS通信に対応させ `https://localhost:8443` でアクセスできるようにする。

自己署名証明書は `.certificate/` ディレクトリに発行済み:
- `.certificate/localhost-cert.pem` (証明書)
- `.certificate/localhost-key.pem` (秘密鍵)

---

## 現状の構成

```
ホスト :8080  →  コンテナ :3000 (Puma HTTP)
```

| ファイル | 現状 |
|---|---|
| `config/puma.rb` | `port ENV.fetch("PORT", 8080)` でHTTP待ち受け（実行時は`rails server`のデフォルトで3000） |
| `docker-compose.yml` | `8080:3000` でポートマッピング |
| `Dockerfile` | `EXPOSE 8080`, CMD: `./bin/rails server -b 0.0.0.0` |

---

## アプローチの比較

HTTPS化には主に2つのアプローチがある。

### アプローチA: Puma SSL直接設定

PumaにSSL証明書を直接設定し、Puma自体がHTTPSを処理する。

**メリット:**
- 追加サービス不要（構成がシンプル）
- 変更箇所が少ない

**デメリット:**
- PumaがSSL終端を負うため、本番との構成差が大きくなる可能性
- SSL関連のPumaオプションの理解が必要

### アプローチB: Nginxリバースプロキシ

NginxコンテナをSSL終端として配置し、バックエンドへはHTTPで転送する。

**メリット:**
- 本番環境に近い構成（Nginx + Puma は一般的な組み合わせ）
- Pumaの設定を変更しなくてよい
- HSTS、リダイレクト等の設定が容易

**デメリット:**
- docker-composeにNginxサービスを追加する必要がある
- Nginx設定ファイルの管理が増える

---

## 推奨: アプローチA（Puma SSL直接設定）

開発環境のHTTPS化が目的であり、構成のシンプルさを優先してアプローチAを推奨する。
変更箇所が最小限で、学習コストも低い。

> [!NOTE]
> 本番環境ではNginx等のリバースプロキシを前段に置くのが一般的だが、
> 開発用途であればPuma直接SSLで十分である。

---

## 変更内容

### 1. `config/puma.rb` の変更

`ssl_bind` を追加し、開発環境でHTTPSを有効にする。

```ruby
# 現在の設定
port ENV.fetch("PORT", 8080)

# 追加する設定（development環境のみ）
if ENV.fetch("RAILS_ENV", "development") == "development"
  ssl_bind '0.0.0.0', ENV.fetch("SSL_PORT", 3443), {
    key: ENV.fetch("SSL_KEY_PATH", "/rails/certs/localhost-key.pem"),
    cert: ENV.fetch("SSL_CERT_PATH", "/rails/certs/localhost-cert.pem"),
    verify_mode: 'none'
  }
end
```

> [!IMPORTANT]
> `verify_mode: 'none'` は自己署名証明書のため必須。本番では適切な検証モードを使用すること。

### 2. `docker-compose.yml` の変更

- 証明書ディレクトリをコンテナにマウント
- HTTPSポートのマッピングを追加

```yaml
services:
  api:
    ports:
      - '8080:3000'      # HTTP（既存）
      - '8443:3443'      # HTTPS（追加）
    volumes:
      - .:/rails
      - ../../.certificate:/rails/certs:ro   # 証明書マウント（追加）
```

| ポート | プロトコル | 用途 |
|---|---|---|
| `8080:3000` | HTTP | 既存（後方互換のため維持） |
| `8443:3443` | HTTPS | 新規追加 |

> [!NOTE]
> 証明書は `../../.certificate` に相対パスで参照。docker-compose.ymlの場所（`apps/api/`）から見た相対パスである。
> `:ro`（read-only）でマウントすることでコンテナ内からの書き換えを防止。

### 3. `.env.example` への追加（任意）

```
SSL_PORT=3443
SSL_KEY_PATH=/rails/certs/localhost-key.pem
SSL_CERT_PATH=/rails/certs/localhost-cert.pem
```

### 4. `README.md` の更新

HTTPS アクセス方法と証明書の配置手順を追記する。

---

## 変更しないファイル

| ファイル | 理由 |
|---|---|
| `Dockerfile` | 開発環境固有の設定であり、Dockerfileは本番向けのため変更しない |
| `Makefile` | `make up` コマンド自体は変更不要（docker-compose upがHTTPSポートも起動する） |
| `config/environments/development.rb` | Rails側にHTTPS固有の設定は不要 |
| テストコード | request specはHTTP/HTTPSに依存しないため変更不要 |

---

## 検証計画

### 自動テスト

既存のテストが引き続きパスすることを確認する:

```bash
make up
make test
```

### 手動テ証

#### 1. HTTPSアクセスの確認

```bash
# コンテナ起動
make up

# HTTPS で疎通確認（-k は自己署名証明書のため）
curl -k https://localhost:8443/api/auth/me

# 期待結果: 401 Unauthorized のJSONレスポンス（未認証のため）
```

#### 2. HTTPアクセスの後方互換

```bash
# HTTP がまだ動くことを確認
curl http://localhost:8080/api/auth/me

# 期待結果: 401 Unauthorized のJSONレスポンス
```

#### 3. Puma起動ログの確認

```bash
make logs
# 以下のようなSSLバインドのログが表示されることを確認:
# * Listening on ssl://0.0.0.0:3443?...
# * Listening on http://0.0.0.0:3000
```

---

## 判断が必要な事項

以下の点について確認をお願いします:

1. **アプローチの選択**: アプローチA（Puma SSL直接設定）でよいか？それともアプローチB（Nginx）を希望するか？
2. **HTTPの維持**: HTTPアクセス（`:8080`）は引き続き維持するか？それともHTTPSのみにするか？
3. **ポート番号**: HTTPS用ポートは `8443` でよいか？
