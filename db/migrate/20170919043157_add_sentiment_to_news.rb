class AddSentimentToNews < ActiveRecord::Migration[5.1]
  def change
    add_column :news, :sentiment_score, :float
    add_column :news, :sentiment_magnitude, :float
  end
end
