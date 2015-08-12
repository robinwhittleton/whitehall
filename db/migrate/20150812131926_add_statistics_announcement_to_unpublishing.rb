class AddStatisticsAnnouncementToUnpublishing < ActiveRecord::Migration
  def change
    add_column :unpublishings, :statistics_announcement_id, :integer
    add_index :unpublishings, :statistics_announcement_id
  end
end
