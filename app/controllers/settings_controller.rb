class SettingsController < ApplicationController

  def index
    @settings = Setting.all
  end

  # PATCH/PUT /members/:member_id/notes/1
  def update
    p params
    p setting_params
    setting_params.each do |key, value| 
      setting = Setting.find_by(lookup: key.to_s).update(value: value)
    end
    redirect_to settings_path, notice: 'Settings were updated'
  end

  private
    # Only allow a trusted parameter "white list" through.
    def setting_params
      params.require(:setting).permit(setting_lookup_values)
    end

    def setting_lookup_values
      Setting.pluck(:lookup).map{|x| x.to_sym}
    end
end
