class RemovePrimaryFromAddresses < ActiveRecord::Migration
  def change
    remove_column :addresses, :primary, :boolean
  end
end
