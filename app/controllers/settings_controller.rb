class SettingsController < ApplicationController

  def index
    @club_name = Setting.where(lookup: "club_name").first
    @other_clubs = Setting.where(lookup: "other_clubs").first
  end

  # PATCH/PUT /members/:member_id/notes/1
  def update
    @club_name = Setting.where(lookup: "club_name").first
    @other_clubs = Setting.where(lookup: "other_clubs").first
    if setting_params[:club_name]
      @club_name.update(value: setting_params[:club_name])
    elsif setting_params[:other_clubs]      
      @other_clubs.update(value: setting_params[:other_clubs])
    end
    redirect_to @settings, notice: 'Settings were updated'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def setting_params
      params.require(:setting).permit(:club_name, :other_clubs)
    end
end
