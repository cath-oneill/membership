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
        csv << (column_names)
        all.each do |member|
          csv << member.attributes.values_at(*column_names)
        end
      end
    end

  end

end
