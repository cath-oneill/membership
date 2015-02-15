module ApplicationHelper

  def club_name
    Setting.find_by(lookup: "club_name").value
  end

  def payment_kinds
    Setting.find_by(lookup: "payment_kinds").value.scan(/\w+/) 
  end  
end
