class AdminController < ApplicationController
  # GET /admin
  def index
    @users = User.all
    @new_user = User.new
  end

  # POST /admin
  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to admin_index_path, notice: 'Administrator was successfully created.' 
    else
      redirect_to admin_index_path, notice: 'Administrator was not successfully created.'
    end
  end

  # DELETE /admin/1
  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to admin_index_path, notice: 'Administrator was successfully destroyed.'
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:email, :password)
    end
end