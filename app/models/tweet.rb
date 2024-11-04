class Tweet < ApplicationRecord
    belongs_to :user
    validates :date, presence: true, allow_blank: true  #日付を空にすることを許可
    validates :day_of_week, presence: true, allow_blank: true  # 曜日を空にすることを許可
    validates :start_time, presence: true, allow_blank: true  # 時間を空にすることを許可
    validates :end_time, presence: true, allow_blank: true  # 時間を空にすることを許可
end
