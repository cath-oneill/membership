class RemoveColumnsFromMembers < ActiveRecord::Migration
  def change
    remove_column :members, :address, :string
    remove_column :members, :address2, :string
    remove_column :members, :city, :string
    remove_column :members, :state, :string
    remove_column :members, :zip, :string
    remove_column :members, :skip_mail, :boolean
    remove_column :members, :mail_name, :string
    remove_column :members, :greeting, :string

    add_column    :members, :middle_name, :string
  end
end
