module MembersHelper

  def combine_with_space(array)
    array.reject!(&:blank?)
    array.join(" ")
  end

  def combine_with_commas(array)
    array.reject!(&:blank?)
    array.join(", ")
  end

  def phone_list
    hash = {"cell" => @member.cell_phone, "home" => @member.home_phone, "work" => @member.work_phone}
    hash.reject! { |k, v| v.blank? }
    hash.map {|k,v| "#{v} (#{k})"}.join(", ")   
  end
end
