class CacheService

  def self.store_session_data(user, session)
    $redis.set(user.id.to_s, user.to_json(only: [:_id, :email, :first_name, :last_name]))
    session[:user_id] = user.id.to_s
  end

  def self.has_active_session(session)
    return session[:user_id]
  end

  def self.get_session_user(session)
    jsonUser = JSON.parse($redis.get(session[:user_id]))

    user = User.new
    user.id = jsonUser['_id']
    user.email = jsonUser['email']
    user.first_name = jsonUser['first_name']
    user.last_name = jsonUser['last_name']

    return user
  end

  def self.remove_session(session)
    $redis.del(session[:user_id])
    session.destroy
  end
end