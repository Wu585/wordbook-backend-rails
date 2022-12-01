class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.integer :user_id
      t.integer :amount
      t.text :notes
      t.integer :tags_id, array:true
      t.datetime :happened_at

      t.timestamps
    end
  end
end
