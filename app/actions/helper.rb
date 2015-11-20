helpers do
  
  def current_user
    begin
      @current_user = User.find(session[:user_id]) if session[:user_id]
    rescue ActiveRecord::RecordNotFound
      session[:user_id] = nil
    end
  end

  def can_vote?(photo, context)
    @current_user.votes.find_by(photo_id: photo.id, context: context).nil?
  end

end