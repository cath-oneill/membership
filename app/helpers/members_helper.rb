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

  def mail_view
    if @member.skip_mail == true
      return "MARKED NO MAIL"
    elsif @member.mail_name.blank? && @member.greeting.blank?
      return "DEFAULT MAILING INFO"
    else
      return "Address Name: #{@member.calculated_mail_name} | Greeting: #{@member.calculated_greeting}"
    end
  end
end
