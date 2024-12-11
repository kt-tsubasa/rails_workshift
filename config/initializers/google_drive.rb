require "google/apis/drive_v3"
require "googleauth"
require "google_drive"

GOOGLE_CLIENT_ID = ENV["GOOGLE_CLIENT_ID"]
GOOGLE_CLIENT_SECRET = ENV["GOOGLE_CLIENT_SECRET"]
GOOGLE_REFRESH_TOKEN = ENV["GOOGLE_REFRESH_TOKEN"]

if GOOGLE_CLIENT_ID && GOOGLE_CLIENT_SECRET && GOOGLE_REFRESH_TOKEN
  # ユーザーリフレッシュクレデンシャルを用意
  authorizer = Google::Auth::UserRefreshCredentials.new(
    client_id: GOOGLE_CLIENT_ID,
    client_secret: GOOGLE_CLIENT_SECRET,
    scope: [
      "https://www.googleapis.com/auth/drive",
      "https://spreadsheets.google.com/feeds/"
    ],
    refresh_token: GOOGLE_REFRESH_TOKEN
  )

  # アクセストークンの更新
  authorizer.fetch_access_token!

  # これでGoogleDrive::Sessionが利用可能になる
  GOOGLE_DRIVE_SESSION = GoogleDrive::Session.from_access_token(authorizer.access_token)
else
  Rails.logger.warn "Google Drive credentials are not set. GOOGLE_DRIVE_SESSION is nil."
  GOOGLE_DRIVE_SESSION = nil
end
