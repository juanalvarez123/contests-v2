class SessionsController < ApplicationController
  layout 'login'

  def new
    if CacheService.has_active_session(session)
      redirect_to contests_path
    end
  end

  def create
    if User.where(email: params[:user][:email], password: (params[:user][:password]).to_s).exists?
      user = User.find_by(email: params[:user][:email], password: (params[:user][:password]).to_s)
      CacheService.store_session_data(user, session)
      redirect_to contests_path
    else
      @errorMessage = "El correo electrónico o contraseña son inválidos"
      render 'new'
    end
  end

  def delete
    delete_session
  end

  def destroy
    delete_session
  end

  private def delete_session
    CacheService.remove_session(session)
    redirect_to login_path
  end
end
