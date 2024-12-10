class TweetsController < ApplicationController

  def index
    @tweets = current_user.tweets 
  end

  def show
    @person_tweet = current_user.tweets.find(params[:id]) 
  end

  def new
    @tweet = Tweet.new
  end

  def create
    (0..6).each do |i|
      next if params[:tweet]["day_of_week_#{i}"].blank?

      # 今日からの次の曜日の日付を計算
      date = Date.today + i

      # 新しいツイートを作成
      Tweet.create!(
        user: current_user,
        date: date, 
        day_of_week: params[:tweet]["day_of_week_#{i}"],
        start_time: params[:tweet]["start_time_#{i}"],
        end_time: params[:tweet]["end_time_#{i}"]
      )
    end
    # 確認画面へリダイレクトする
    redirect_to action: "index"
  end

  def destroy
    tweet = current_user.tweets.find_by(id: params[:id])
    if tweet.present?
      tweet.destroy
      flash[:notice] = 'シフト希望を取り消しました。'
    end
  end

  def export_to_google_sheets
    access_token = session[:google_access_token]
    if access_token.nill?
      redirect_to auth_google_path, notice: "Google認証が必要です"
      return
    end

    session = GoogleDrive::Session.from_access_token(access_token)
    spreadsheet = session.spreadsheet_by_title("シフト表")
    worksheet = spreadsheet.worksheets[0]

    current_user_id = params[:user_id]
    current_user = User.find_by(id: current_user_id)

    if current_user.nil?
      redirect_to top_user_tweets_path, notice: "ユーザーが見つかりませんでした"
      return
    end

    tweets = Tweet.where(user_id: current_user.id)

    (1..worksheet.num_rows).each do |row|
      sheet_name = worksheet[row, 2]
      matching_user = User.find_by(name: sheet_name)

      if matching_user && matching_user.id == current_user.id
        tweets.each do |tweet|
          case tweet.day_of_week
          when "月曜日"
            worksheet[row, 3] = "#{tweet.start_time.hour}:#{format('%02d', tweet.start_time.min)}～#{tweet.end_time.hour}:#{format('%02d', tweet.end_time.min)}"
          when "火曜日"
            worksheet[row, 4] = "#{tweet.start_time.hour}:#{format('%02d', tweet.start_time.min)}～#{tweet.end_time.hour}:#{format('%02d', tweet.end_time.min)}"
          when "水曜日"
            worksheet[row, 5] = "#{tweet.start_time.hour}:#{format('%02d', tweet.start_time.min)}～#{tweet.end_time.hour}:#{format('%02d', tweet.end_time.min)}"
          when "木曜日"
            worksheet[row, 6] = "#{tweet.start_time.hour}:#{format('%02d', tweet.start_time.min)}～#{tweet.end_time.hour}:#{format('%02d', tweet.end_time.min)}"
          when "金曜日"
            worksheet[row, 7] = "#{tweet.start_time.hour}:#{format('%02d', tweet.start_time.min)}～#{tweet.end_time.hour}:#{format('%02d', tweet.end_time.min)}"
          when "土曜日"
            worksheet[row, 8] = "#{tweet.start_time.hour}:#{format('%02d', tweet.start_time.min)}～#{tweet.end_time.hour}:#{format('%02d', tweet.end_time.min)}"
          when "日曜日"
            worksheet[row, 9] = "#{tweet.start_time.hour}:#{format('%02d', tweet.start_time.min)}～#{tweet.end_time.hour}:#{format('%02d', tweet.end_time.min)}"
          end
        end
      end
    end

    begin
      if worksheet.save
        redirect_to new_user_tweet_path(current_user), notice: "Googleスプレッドシートにエクスポートが完了しました"
      else
        Rails.logger.error "Worksheet save failed"
        redirect_to user_tweets_path(current_user), notice: "エクスポートに失敗しました"
      end
    rescue => e
      Rails.logger.error "Error during worksheet save: #{e.message}"
      redirect_to user_tweets_path(current_user), notice: "エクスポート中にエラーが発生しました: #{e.message}"
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:date, :day_of_week, :start_time, :end_time)
  end
end
