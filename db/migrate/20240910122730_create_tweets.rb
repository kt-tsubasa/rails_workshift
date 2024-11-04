class CreateTweets < ActiveRecord::Migration[6.1]
  def change
    create_table :tweets do |t|
      t.references :user, null: false, foreign_key: true
      t.date :date, null: false
      t.string :day_of_week, null: false
      t.time :time, null: false
      t.timestamps
    end
  end
end
