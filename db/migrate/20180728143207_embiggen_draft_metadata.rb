class EmbiggenDraftMetadata < ActiveRecord::Migration[5.2]
  # making this mediumtext so we know it can hold a whole chapter
  def change
    change_column :drafts, :metadata, :text, limit: 16.megabytes - 1
  end
end
