class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update]

  # GET /members
  # GET /members.json
  def index   
    @filterrific = initialize_filterrific(
        Member,
        params[:filterrific],
        :select_options => {
          sorted_by:    Member.options_for_sorted_by,
          zip_select:   Member.options_for_zip_select,
          mail_select:  Member.options_for_mail_select,
          tag_select:   Member.options_for_tag_select
        }) or return  
    @members = @filterrific.find.page(params[:page])

    respond_to do |format|
      format.html
      format.js
      format.csv {
        if params[:csv] == "export_members_csv"
          @members_for_csv = @filterrific.find
          send_data(@members_for_csv.export_members_csv,
            type: 'text/csv', disposition: 'attachment', 
            filename: "members_#{Time.now.to_i}.csv")
        elsif params[:csv] == "export_mailing_csv"
          @members_for_csv = @filterrific.find
          send_data(@members_for_csv.export_mailing_csv,
            type: 'text/csv', disposition: 'attachment', 
            filename: "mailing_#{Time.now.to_i}.csv")
        end
      }
    end

  rescue ActiveRecord::RecordNotFound => e
    # There is an issue with the persisted param_set. Reset it.
    puts "Had to reset filterrific params: #{ e.message }"
    redirect_to(reset_filterrific_url(format: :html)) and return
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
    @member = Member.new(member_params)
    @member.tag_list = member_tag_params["tag_list"]
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
    @member.tag_list = member_tag_params["tag_list"] 
    @member.attributes = member_params
    respond_to do |format|
      if @member.save
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
      params.require(:member).permit(:first_name, :last_name, :email, :email2, :cell_phone, :home_phone, :work_phone, :employer, :occupation, :title, :dues_paid)
    end

    def member_tag_params
      params.require(:member).permit(:tag_list)
    end
end
