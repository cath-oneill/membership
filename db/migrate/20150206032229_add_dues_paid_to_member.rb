class AddDuesPaidToMember < ActiveRecord::Migration
  def change
    add_column :members, :dues_paid, :date
  end
end
