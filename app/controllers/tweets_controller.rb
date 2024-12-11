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

  def export_to_google_sheets
    unless GOOGLE_DRIVE_SESSION
      redirect_to '/oauth2callback', notice: "Google認証情報が見つかりません"
      return
    end

    # ここで対象ユーザーを特定
    current_user_id = params[:user_id]
    target_user = User.find_by(id: current_user_id)

    if target_user.nil?
      redirect_to top_user_tweets_path, notice: "ユーザーが見つかりませんでした"
      return
    end

    # 該当ユーザーのツイート(シフト)を取得
    tweets = Tweet.where(user_id: target_user.id)

    begin
      spreadsheet = GOOGLE_DRIVE_SESSION.spreadsheet_by_title("シフト表")
      worksheet = spreadsheet.worksheets[0]

      (1..worksheet.num_rows).each do |row|
        sheet_name = worksheet[row, 2]
        matching_user = User.find_by(name: sheet_name)

        if matching_user && matching_user.id == target_user.id
          # 曜日によって列を振り分けて書き込み
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

      # 保存を試みる
      if worksheet.save
        redirect_to new_user_tweet_path(target_user), notice: "Googleスプレッドシートにエクスポートが完了しました"
      else
        Rails.logger.error "Worksheet save failed"
        redirect_to user_tweets_path(target_user), notice: "エクスポートに失敗しました"
      end
    rescue => e
      Rails.logger.error "Error during worksheet save: #{e.message}"
      redirect_to user_tweets_path(target_user), notice: "エクスポート中にエラーが発生しました: #{e.message}"
    end
  end

  private

  def tweet_params
    params.require(:tweet).permit(:date, :day_of_week, :start_time, :end_time)
  end
end
