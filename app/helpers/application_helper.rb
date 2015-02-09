module ApplicationHelper

  def club_name
    Setting.where(lookup: "club_name").first.value
  end

  def other_clubs
    Setting.where(lookup: "other_clubs").first.value.scan(/\w+/) 
  end
end
