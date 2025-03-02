class TweetsController < ApplicationController

  def index
    @tweets = current_user.tweets
  end

  def new
    @tweet = Tweet.new
  end

  def create
    (0..6).each do |i|
      next if params[:tweet]["day_of_week_#{i}"].blank?

      date = Date.today + i

      Tweet.create!(
        user: current_user,
        date: date,
        day_of_week: params[:tweet]["day_of_week_#{i}"],
        start_time: params[:tweet]["start_time_#{i}"],
        end_time: params[:tweet]["end_time_#{i}"]
      )
    end
    redirect_to action: "index"
  end

  def destroy
    tweet = current_user.tweets.find_by(id: params[:id])
    if tweet.present?
      tweet.destroy
      flash[:notice] = 'シフト希望を取り消しました。'
    end
    redirect_to action: "index"
  end

  def normalize_name(name)
    # 全角スペースや半角スペースを削除する例
    name.to_s.gsub(/[ \u3000]+/, "")
  end 

  def export_to_google_sheets
    # (前半はリフレッシュトークンやアクセストークン取得の処理)
    refresh_token = ENV['GOOGLE_REFRESH_TOKEN']
    client_id     = ENV['GOOGLE_CLIENT_ID']
    client_secret = ENV['GOOGLE_CLIENT_SECRET']
  
    client = Signet::OAuth2::Client.new(
      client_id:            client_id,
      client_secret:        client_secret,
      token_credential_uri: 'https://oauth2.googleapis.com/token',
      refresh_token:        refresh_token
    )
  
    begin
      client.refresh!
    rescue => e
      Rails.logger.error "Failed to refresh token: #{e.message}"
      redirect_to user_tweets_path(current_user), alert: "Googleアクセストークンの更新に失敗しました"
      return
    end
  
    session = GoogleDrive::Session.from_access_token(client.access_token)
    spreadsheet = session.spreadsheet_by_title("シフト表")
    worksheet = spreadsheet.worksheets[0]
  
    tweets = current_user.tweets
  
    (1..worksheet.num_rows).each do |row|
      sheet_name = worksheet[row, 2]
      
      # normalize_name で余分な空白を除去して比較
      if normalize_name(sheet_name) == normalize_name(current_user.name)
        # ① まず対象ユーザーのシフトセル（例：列3～9）をクリアする
        (3..9).each do |col|
          worksheet[row, col] = ""
        end
        
        # ② 新しいシフト情報を書き込む
        tweets.each do |tweet|
          time_str = "#{tweet.start_time.hour}:#{format('%02d', tweet.start_time.min)}～#{tweet.end_time.hour}:#{format('%02d', tweet.end_time.min)}"
          col_index = case tweet.day_of_week
                      when "月曜日" then 3
                      when "火曜日" then 4
                      when "水曜日" then 5
                      when "木曜日" then 6
                      when "金曜日" then 7
                      when "土曜日" then 8
                      when "日曜日" then 9
                      else
                        nil
                      end
          worksheet[row, col_index] = time_str if col_index
        end
      end
    end
  
    worksheet.save
  
    redirect_to new_user_tweet_path(current_user), notice: "Googleスプレッドシートにエクスポートが完了しました"
  end
  
  private

  def tweet_params
    params.require(:tweet).permit(:date, :day_of_week, :start_time, :end_time)
  end
end
