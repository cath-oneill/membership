class MembersController < ApplicationController
  before_action :set_member, only: [:show, :edit, :update]

  # GET /members
  # GET /members.json
  def index
    @filterrific = Filterrific.new(Member, params[:filterrific])
    @members = Member.filterrific_find(@filterrific) #.page(params[:page])
    #@members = Member.all
  end

  # GET /members/1
  # GET /members/1.json
  def show
    #raise 'x'
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
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :ok, location: @member }
      else
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(:first_name, :last_name, :address, :city, :state, :zip, :email, :cell_phone, :home_phone, :work_phone, :employer, :occupation, :title)
    end
end
