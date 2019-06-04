class OptionsController < ApplicationController
  layout 'admin'

  def index
    if CacheService.has_active_session(session)
      @user = CacheService.get_session_user(session)
      @option = Option.new

      option = Option.all.where(name: 'EMAIL_SERVICE').first
      @option.value_EMAIL_SERVICE = option.value.eql?('true') ? 1 : 0
    else
      redirect_to login_path
    end
  end

  def update
    if CacheService.has_active_session(session)
      @user = CacheService.get_session_user(session)
      @option = Option.new

      option = Option.all.where(name: 'EMAIL_SERVICE').first
      option.update_attribute(:value, (params[:option][:value_EMAIL_SERVICE]).eql?('1') ? 'true' : 'false')
      @option.value_EMAIL_SERVICE = option.value.eql?('true') ? 1 : 0

      render 'index'
    else
      redirect_to login_path
    end
  end
end
