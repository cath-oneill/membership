class AddressesController < ApplicationController
  before_action :set_address, only: [:show, :edit, :update]
  before_action :set_member, only: [:new, :edit, :create, :update]  

  # GET /members/:member_id/notes/new
  def new
    @address = Address.new
  end

  # GET /members/:member_id/notes/1/edit
  def edit
    #raise 'x'
  end

  # POST /members/:member_id/notes
  def create
    @address = Address.new
    @address.member_id = @member.id
    @address.update(address_params)
    if @address.save
      update_primary_address  
      redirect_to @member, notice: 'Address was successfully created.'
    else
      render new_member_address_path
    end
  end

  # PATCH/PUT /members/:member_id/notes/1
  def update
    if @address.update(address_params)
      update_primary_address      
      redirect_to @member, notice: 'Address was successfully updated.'
    else
      render edit_member_address_path
    end
  end

  def duplicate_address_report
    respond_to do |format|
      format.csv {send_data(Address.duplicated_address_csv,
            type: 'text/csv', disposition: 'attachment', 
            filename: "duplicate_addresses_#{Time.now.to_i}.csv")}
    end
  end  

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_address
      @address = Address.find(params[:id])
    end

    def set_member
      @member = Member.find(params[:member_id])
    end    

    # Only allow a trusted parameter "white list" through.
    def address_params
      params.require(:address).permit(:address1, :address2, :city, :state, :zip,  :skip_mail, :addressee, :greeting)
    end 

    def update_primary_address
      if params["primary"] == "1" && @member.primary_address_id != @address.id
        @member.primary_address_id = @address.id    
        @member.save
      end    
    end   
end