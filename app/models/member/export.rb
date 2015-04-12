module Member::Export
  extend ActiveSupport::Concern

  module ClassMethods    

    def export_mailing_csv
      CSV.generate do |csv|
        columns = ["addressee", "address1", "address2",  "city", "state", "zip", "greeting"]
        csv << columns
        all.each do |member|
          member.addresses.each do |add|
            next if add.skip_mail == true
            information = add.attributes.values_at("address1", "address2",  "city", "state", "zip")
            information.unshift(add.calculated_addressee)
            information.push(add.calculated_greeting)
            csv << information
          end
        end
      end    
    end 

    def export_members_csv
      CSV.generate do |csv|
        columns = %w(id first_name middle_name last_name email email2 home_phone 
          cell_phone work_phone employer occupation created_at dues_paid addressee 
          address1 address2 city state zip greeting)
        csv << columns
        all.each do |member|
          csv << columns.map{|c| member.send(c)}
        end
      end
    end

  end

end
