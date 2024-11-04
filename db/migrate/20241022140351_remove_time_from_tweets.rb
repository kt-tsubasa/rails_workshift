class RemoveTimeFromTweets < ActiveRecord::Migration[6.1]
  def change
    remove_column :tweets, :time, :time
  end
end
