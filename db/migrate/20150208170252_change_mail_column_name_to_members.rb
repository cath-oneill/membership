class ChangeMailColumnNameToMembers < ActiveRecord::Migration
  def change
    rename_column :members, :mail_address, :mail_name
  end
end
