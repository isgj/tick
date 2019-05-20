class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.string :state
      t.references :host, null: false, foreign_key: {to_table: :users}
      t.references :guest, null: true, foreign_key: {to_table: :users}
      t.integer :next_player
      t.integer :winner

      t.timestamps
    end
  end
end
