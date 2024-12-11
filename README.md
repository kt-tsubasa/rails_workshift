# README

# シフト希望提出アプリケーション

## 概要
このアプリケーションは、シフトの希望から簡単にシフト作成ができるようにするために作られたWebアプリです。ユーザーがログインして日付、曜日、開始時間、終了時間を選択し、シフトの希望を登録することができます。提出されたシフト情報は、Googleスプレッドシートに登録され、管理者が確認・管理するための機能を備えています。

## 特徴
- **ユーザー認証**: Deviseを使用してユーザー管理と認証を実装。
- **シフト希望提出**: 曜日、開始時間、終了時間を選択して提出。
- **Googleスプレッドシート連携**: 提出されたデータをGoogle Sheetsに保存。
- **視覚的なUI**: Bootstrapを使用して、わかりやすいフォームデザインを提供。

## 使用技術
- **フロントエンド**: HTML, CSS, Bootstrap
- **バックエンド**: Ruby on Rails
- **データベース**: PostgreSQL (開発環境ではSQLite3)
- **認証ライブラリ**: Devise
- **外部API**: Google Sheets API

## 基本情報
- **Rubyのバージョン**: ruby-3.1.6

## システム依存関係
このアプリを動かすために必要なライブラリやツールについては、`Gemfile`に記載されています。`bundle install`コマンドを使用して依存関係をインストールしてください。

## 設定
1. Google APIの認証情報を取得し、`credentials.json`ファイルを`config`ディレクトリに配置します。
2. 必要な環境変数を設定します。`.env`ファイルを作成し、以下のように記述してください。
   ```dotenv
   GOOGLE_CLIENT_ID=your_google_client_id
   GOOGLE_CLIENT_SECRET=your_google_client_secret
   GOOGLE_REFRESH_TOKEN=your_google_refresh_token
