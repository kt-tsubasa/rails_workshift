# get_refresh_token.rb (あくまで例: 独立したスクリプト)
require 'signet/oauth_2/client'
# require 'launchy' # gem install launchy

# あなたのGCPで作成したOAuthクライアントID, シークレット
CLIENT_ID     = "your_id"
CLIENT_SECRET = "your_secret"
REDIRECT_URI  = "http://localhost:3000/oauth2callback" # 適宜合わせる

client = Signet::OAuth2::Client.new(
  client_id: CLIENT_ID,
  client_secret: CLIENT_SECRET,
  authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
  token_credential_uri: 'https://oauth2.googleapis.com/token',
  scope: [
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/spreadsheets'
  ],
  redirect_uri: REDIRECT_URI
)

# ブラウザでアクセスする認可URLを生成
auth_url = client.authorization_uri.to_s

puts "次のURLをブラウザで開いてGoogle認証してください:"
puts auth_url
# Launchy.open(auth_url) if defined?(Launchy)

puts "ブラウザで認証後、リダイレクト先のURLに含まれる 'code' パラメータをここに貼り付けてください:"
print "Code: "
code = gets.chomp

client.code = code
token_response = client.fetch_access_token!

puts "Access Token: #{token_response['access_token']}"
puts "Refresh Token: #{token_response['refresh_token']}"

# ここで表示される refresh_token をメモしておき、Herokuに設定する
