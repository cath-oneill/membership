class AddMemberRefToNotes < ActiveRecord::Migration
  def change
    add_reference :notes, :member, index: true
  end
end
