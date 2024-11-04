class AddStartAndEndTimeToTweets < ActiveRecord::Migration[6.1]
  def change
    add_column :tweets, :start_time, :time
    add_column :tweets, :end_time, :time
  end
end
