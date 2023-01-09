class CreateWords < ActiveRecord::Migration[7.0]
  def change
    create_table :words do |t|
      t.references :user, null: false, foreign_key: false
      t.string :content, null: false
      t.string :description, null: false
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
