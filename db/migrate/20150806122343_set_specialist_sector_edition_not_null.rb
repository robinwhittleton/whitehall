class SetSpecialistSectorEditionNotNull < ActiveRecord::Migration
  def change
    SpecialistSector.delete_all :edition_id => nil
    change_column_null :specialist_sectors, :edition_id, false
  end
end
