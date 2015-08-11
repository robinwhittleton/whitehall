class AddStatisticsAnnouncementsUnpublishedFlag < ActiveRecord::Migration
  def change
    add_column :statistics_announcements, :unpublished, :boolean, default: false
  end
end
