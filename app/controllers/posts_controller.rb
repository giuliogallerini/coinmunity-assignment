class PostsController < BaseController

  skip_before_action :authenticate, only: [:index, :show]
  def index
    posts = Post.where(is_spam: false).sort_by {|post| post.created_at}.reverse

    respond_to do |format|
      format.json{render status:200, json: posts.as_json(
        except: :content,
        include: [
          { user: { only: [:id, :trustiness, :silenced], include: { profile: { only: [:id, :nickname, :picture] } } } },
          { tags: { only: [:id, :name] } },
          { trusts: { only: :id } },
          { reports: { only: :id } },
          { comments: { only: :id } },
          ] ) }
    end
  end

  def show
    post = Post.find(params[:id])

    respond_to do |format|
      format.json{render status:200, json: post.as_json(
        except: :summary,
        include: [
          { user: { only: [:id, :trustiness, :silenced], include: { profile: { only: [:id, :nickname, :picture] } } } },
          { tags: { only: [:id, :name] } },
          { trusts: { include: { user: { only: [:id, :trustiness, :silenced], include: { profile: { only: [:id, :nickname, :picture] } } } } } },
          { reports: { include: { user: { only: [:id, :trustiness, :silenced], include: { profile: { only: [:id, :nickname, :picture] } } } } } },
          { comments: { include: { user: { only: [:id, :trustiness, :silenced], include: { profile: { only: [:id, :nickname, :picture] } } } } } },
          ] ) }
    end
  end

  def create
    temp_params = post_params
    temp_params[:tag_ids] = tags_params
    temp_params[:user_id] = @user.id if !@user.nil?

    return render status: 401, json: {
      success: false,
      message: 'Your trustiness score is too low to post!'
    } if @user.silenced

    post = Post.new(temp_params)
    post.summary = post.summarize

    if post.save
      # render notice: "Post created",json: post.as_json

      jsonPost = post.as_json(
        except: :content,
        include: [
          { user: { only: [:id, :trustiness, :silenced], include: { profile: { only: [:id, :nickname, :picture] } } } },
          { tags: { only: [:id, :name] } },
          ] )

      render notice: "Post created",json: jsonPost

      # ActionCable.server.broadcast("PostsChannel", jsonPost)
    else
      render notice: "Post not created", json: post.errors.full_messages
    end
  end

  def destroy
    post = Post.find(params[:id])

    return render status: 401, json: {
      success: false,
      message: 'You cannot delete other users posts!'
    } if @user.id != post.user_id

    if post.destroy
      render status: 200, json: {
        success: true,
        message: 'Post removed'
      }
    else
      render status: 400, json: {
        success: false,
        message: post.errors.full_messages
      }
    end
  end

  private

  def tags_params
    params.require(:tag_ids)
  end

  def post_params
    params.require(:post).permit(:content, :link, :images, :user_id, :tags)
  end
end
