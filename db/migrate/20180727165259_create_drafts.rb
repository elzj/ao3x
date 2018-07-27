class CreateDrafts < ActiveRecord::Migration[5.2]
  def change
    create_table :drafts do |t|
      t.references :user, null: false
      t.text :metadata
    end
    add_index :drafts, :user_id
  end
end
