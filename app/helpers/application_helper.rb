module ApplicationHelper

  def club_name
    Setting.where(lookup: "club_name").first.value
  end
end
