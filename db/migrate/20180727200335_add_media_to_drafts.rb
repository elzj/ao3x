class AddMediaToDrafts < ActiveRecord::Migration[5.2]
  def change
    add_column :drafts, :media_data, :text
  end
end
