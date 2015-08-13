module Member::Import
  extend ActiveSupport::Concern

  include Importable

  module ClassMethods

    def import_new(file)
      not_created = []
      check_headers(file, "first_name", "last_name")

      CSV.foreach(file.path, headers: true) do |row|
        member_hash = create_hash(row)
        if hash_has_required_fields?(member_hash, "first_name", "last_name")
          if member_already_exists?(member_hash)
            not_created << "Row #{$.} member already exists: #{member_hash["first_name"]} #{member_hash["last_name"]}."
          else
            create_member(member_hash)
          end
        else
          not_created << "Row #{$.} missing required information: first name or last name."
        end # end hash_has_require_fields?
      end # end CSV.foreach
      return not_created
    end # end self.import(file)

    private

    def member_already_exists?(member_hash)
      Member.where("LOWER(first_name) = ?", member_hash["first_name"].downcase).where("LOWER(last_name) = ?", member_hash["last_name"].downcase).exists?
    end

    def create_member(member_hash)
      member_attributes  =  member_hash.select{|k, v| Member.columns.map(&:name).include?(k)}
      address_attributes =  member_hash.select{|k, v| Address.columns.map(&:name).include?(k)}
      tags               =  member_hash["tags"].split(",").map{|x| x.strip} unless member_hash["tags"].nil?
      note               =  member_hash["note"] unless member_hash["note"].nil?
      new_member                 = Member.create!(member_attributes)
      new_member.primary_address = Address.create!(address_attributes)
      Note.create!(date: Date.today, content: note, member_id: new_member.id) unless member_hash["note"].nil?
      new_member.update(primary_address_id: new_member.primary_address.id)
      new_member.tag_list.add(tags) unless member_hash["tags"].nil?
    end

  end
end