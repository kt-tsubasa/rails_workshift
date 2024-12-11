require 'googleauth'

# 事前に取得したクライアントIDとシークレットをセット
client_id = "YOUR_CLIENT_ID"
client_secret = "YOUR_CLIENT_SECRET"

# 要求するスコープ
scopes = [
  "https://www.googleapis.com/auth/drive",
  "https://spreadsheets.google.com/feeds/"
]

# デバイスやWebサーバーでない純粋なローカルスクリプトから認可を行う場合
# OOB(Out-of-band)フローを利用します（以下のURIをリダイレクト先として使う）
redirect_uri = 'urn:ietf:wg:oauth:2.0:oob'

client = Signet::OAuth2::Client.new(
  client_id: client_id,
  client_secret: client_secret,
  authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
  token_credential_uri: 'https://oauth2.googleapis.com/token',
  scope: scopes,
  redirect_uri: redirect_uri,
  access_type: 'offline',      # offlineを指定することでrefresh_tokenが返ってくる
  prompt: 'consent'            # 毎回同意画面を表示してrefresh_tokenを取得させる
)

# 認可URLを表示
puts "1. 以下のURLをブラウザで開いて認証を許可してください:\n#{client.authorization_uri}\n\n"
puts "2. 認可後、表示されたコードをここに貼り付けてEnterを押してください:"

# コード入力待ち
code = gets.chomp

# コードを使ってトークンを取得
client.code = code
client.fetch_access_token!

# 取得結果を表示
puts "Access Token: #{client.access_token}"
puts "Refresh Token: #{client.refresh_token}"

# Refresh Tokenを `.env` やファイルに保存
# ここでは単純に出力例:
puts "このRefresh Tokenを環境変数やcredentialsに保存してください: #{client.refresh_token}"
