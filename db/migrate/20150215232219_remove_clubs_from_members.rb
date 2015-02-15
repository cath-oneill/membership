class RemoveClubsFromMembers < ActiveRecord::Migration
  def change
    remove_column :members, :clubs, :text
  end
end
