class AddColumnsToMembers < ActiveRecord::Migration
  def change
    add_column :members, :skip_mail, :boolean
    add_column :members, :mail_address, :string
    add_column :members, :greeting, :string
    add_column :members, :clubs, :text
  end
end
