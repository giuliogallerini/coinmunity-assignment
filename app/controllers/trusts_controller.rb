class TrustsController < BaseController

  def create
    temp_params = trust_params
    temp_params[:user_id] = @user.id if !@user.nil?

    return render status: 401, json: {
      success: false,
      message: 'You cannot trust with a trustiness below 0!'
    } if @user.trustiness < 0

    return render status: 401, json: {
      success: false,
      message: 'You cannot trust your own posts!'
    } if @user == Post.find(trust_params[:post_id]).user

    @trust = Trust.new(temp_params)

    if @trust.save
      @trust.post.user.update_trustiness(@trust.trust_trustiness)
      render notice: "Trust created", json: @trust.as_json(
        include: { user: { only: [:id, :trustiness, :silenced], include: { profile: { only: [:id, :nickname, :picture] } } } }
      )
    else
      render notice: "Trust not created", json: @trust.errors.full_messages
    end
  end

  private

  def trust_params
    params.require(:trust).permit(:source_id, :comment, :screenshot, :link, :post_id , :user_id)
  end
end
