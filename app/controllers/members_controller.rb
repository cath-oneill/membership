class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update]

  # GET /members
  # GET /members.json
  def index
    @filterrific = initialize_filterrific(
      Member,
      params[:filterrific],
      :select_options => {
        sorted_by: Member.options_for_sorted_by,
        by_zip_code: Member.options_for_zip_select
      }) or return
    @members = @filterrific.find.page(params[:page])
    @members_for_csv = @filterrific.find


    respond_to do |format|
      format.html
      format.js
      format.csv {render text: @members_for_csv.to_csv}
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
  end

  def duplicate_address_report
    @duplicates = Member.where.not(address: [nil, ""]).select(:address).group(:address).having("count(*) > 1")
    respond_to do |format|
      format.csv {render text: @duplicates.duplicated_address_csv}
    end
  end

  # GET /members/1
  # GET /members/1.json
  def show
  end

  # GET /members/new
  def new
    @member = Member.new
  end

  # GET /members/1/edit
  def edit
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(formatted_member_params)

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully created.' }
        format.json { render :show, status: :created, location: @member }
      else
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    p member_params
    respond_to do |format|
      if @member.update(formatted_member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  def import_new
    response = Member.import_new(params[:file])
    if response.empty?
      redirect_to members_path, notice: "All rows imported and created."
    else 
      redirect_to members_path, alert: "#{response.length} rows rejected: #{response.join(", ")}"
    end  
  rescue Exception => e
      redirect_to payments_path, alert: e 
  end

  def import_update
    response = Member.import_update(params[:file])
    if response.empty?
      redirect_to members_path, notice: "All rows imported and updated."
    else 
      redirect_to members_path, alert: "#{response.length} rows rejected: #{response.join(", ")}"
    end  
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(:first_name, :last_name, :address, :address2, :city, :state, :zip, :email, :email2, :cell_phone, :home_phone, :work_phone, :employer, :occupation, :title, :dues_paid, :skip_mail, :mail_name, :greeting)
    end

    def formatted_member_params
      clubs = params["clubs"]
      new_params = member_params
      unless clubs.nil?
        new_params["clubs"] = clubs.keys
      end
      new_params
    end
end
