# リファクタリング計画

> 基づくドキュメント: [architecture_review_20260504.md](./architecture_review_20260504.md)

## 概要

アーキテクチャレビューで指摘された課題に対し、**Service 層の導入**を軸にリファクタリングを行う。  
既存の機能・テストを壊さずに、段階的にコントローラーを薄くしていく方針。

---

## リファクタリング後の構成

```text
app/
├── controllers/
│   ├── concerns/
│   │   └── authenticable.rb              # 変更なし
│   └── api/auth/
│       ├── users_controller.rb           # Service 呼び出しに置換
│       ├── sessions_controller.rb        # Service 呼び出しに置換
│       └── refreshes_controller.rb       # Service 呼び出しに置換
├── services/
│   └── auth/
│       ├── signup_service.rb             # [NEW] ユーザー登録
│       ├── login_service.rb              # [NEW] ログイン（認証 + トークン発行）
│       ├── logout_service.rb             # [NEW] ログアウト（トークン無効化）
│       ├── refresh_service.rb            # [NEW] トークンリフレッシュ
│       └── token_service.rb             # [NEW] トークン生成/検証/破棄（共通）
└── models/
    └── user.rb                           # バリデーション追加
```

---

## タスク一覧

### Phase 1: 基盤整備

#### Task 1-1: `Auth::TokenService` の作成
- **ファイル**: `app/services/auth/token_service.rb` [NEW]
- **内容**:
  - `issue_tokens(user)` — アクセストークン + リフレッシュトークンをペアで生成し、Redis に保存
  - `revoke_refresh_token(token)` — リフレッシュトークンを Redis から削除
  - `find_user_by_refresh_token(token)` — リフレッシュトークンで Redis を検索し User を返す
  - リフレッシュトークンの有効期限（`7.days`）を定数化
  - Redis のキープレフィックス（`refresh_token:`）を定数化
- **目的**: sessions_controller と refreshes_controller に散在するトークン生成・Redis 操作を一元化（DRY）

#### Task 1-2: User モデルにバリデーション追加
- **ファイル**: `app/models/user.rb` [MODIFY]
- **内容**:
  ```ruby
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  ```
- **目的**: DB 制約に加え、モデル層で適切なエラーメッセージを生成する

---

### Phase 2: Service 層の実装

#### Task 2-1: `Auth::SignupService` の作成
- **ファイル**: `app/services/auth/signup_service.rb` [NEW]
- **内容**:
  - `call(name:, email:, password:, password_confirmation:)` — User を作成し、結果を返す
  - 成功時: `{ success: true, user: user }`
  - 失敗時: `{ success: false, errors: user.errors.full_messages }`

#### Task 2-2: `Auth::LoginService` の作成
- **ファイル**: `app/services/auth/login_service.rb` [NEW]
- **内容**:
  - `call(email:, password:)` — ユーザー認証 + `TokenService.issue_tokens` 呼出
  - 成功時: `{ success: true, payload: { uuid:, access_token:, refresh_token: } }`
  - 失敗時: `{ success: false, error: "Invalid email or password" }`

#### Task 2-3: `Auth::LogoutService` の作成
- **ファイル**: `app/services/auth/logout_service.rb` [NEW]
- **内容**:
  - `call(refresh_token:)` — `TokenService.revoke_refresh_token` 呼出

#### Task 2-4: `Auth::RefreshService` の作成
- **ファイル**: `app/services/auth/refresh_service.rb` [NEW]
- **内容**:
  - `call(refresh_token:)` — 旧トークン検証・破棄 → 新トークンペア発行
  - 成功時: `{ success: true, payload: { access_token:, refresh_token: } }`
  - 失敗時: `{ success: false, error: "Invalid refresh token" }`

---

### Phase 3: コントローラーのリファクタリング

#### Task 3-1: `UsersController` のリファクタ
- **ファイル**: `app/controllers/api/auth/users_controller.rb` [MODIFY]
- **内容**: `create` アクションで `Auth::SignupService.call` を呼ぶ形に変更。`me` アクションはそのまま。

#### Task 3-2: `SessionsController` のリファクタ
- **ファイル**: `app/controllers/api/auth/sessions_controller.rb` [MODIFY]
- **内容**:
  - `create` → `Auth::LoginService.call`
  - `destroy` → `Auth::LogoutService.call`

#### Task 3-3: `RefreshesController` のリファクタ
- **ファイル**: `app/controllers/api/auth/refreshes_controller.rb` [MODIFY]
- **内容**: `create` → `Auth::RefreshService.call`

---

### Phase 4: テスト

#### Task 4-1: Service 層のユニットテスト追加
- **ファイル**: 
  - `test/services/auth/token_service_test.rb` [NEW]
  - `test/services/auth/signup_service_test.rb` [NEW]
  - `test/services/auth/login_service_test.rb` [NEW]
  - `test/services/auth/logout_service_test.rb` [NEW]
  - `test/services/auth/refresh_service_test.rb` [NEW]
- **内容**: 各 Service のロジックを直接テスト

#### Task 4-2: 既存コントローラーテストの通過確認
- **内容**: 既存の結合テスト3ファイルがそのまま全てパスすることを確認
  - `test/controllers/api/auth/users_controller_test.rb`
  - `test/controllers/api/auth/sessions_controller_test.rb`
  - `test/controllers/api/auth/refreshes_controller_test.rb`

---

## 検証方法

### 自動テスト

```bash
# apps/api ディレクトリで実行（Docker 環境）
make test

# 特定ファイルの実行
make test file=test/services/auth/token_service_test.rb
```

### 手動確認

1. `make up` でコンテナ起動
2. 以下のエンドポイントを curl 等で動作確認：
   - `POST /api/auth/signup` — ユーザー登録
   - `POST /api/auth/login` — ログイン
   - `POST /api/auth/refresh` — トークン更新
   - `POST /api/auth/logout` — ログアウト
   - `GET /api/auth/me` — ユーザー情報取得

---

## 方針メモ

- **破壊的変更なし**: API のレスポンス形式は一切変更しない
- **段階的に進める**: Phase ごとにテストを通して進める。特に Phase 3 の各コントローラー変更後は既存テストで回帰確認
- **RSpec のテスト (`users_spec.rb`) は触らない**: Minitest のコントローラーテストで回帰確認する
- **`Authenticable` concern は変更なし**: 認証ミドルウェアとしての役割は現状のまま
