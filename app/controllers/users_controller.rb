class UsersController < ApplicationController
  load_and_authorize_resource

  # GET /users/1
  def show
    @events = @user.events.where(state: :confirmed)
  end

  # GET /users/1/edit
  def edit
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      redirect_to @user, notice: 'User was successfully updated.'
    else
      flash.now[:error] = "An error prohibited your Profile from being saved: #{@user.errors.full_messages.join('. ')}."
      render :edit
    end
  end

  def signed_in_user
    if current_user
      redirect_to "#{params[:redirect_path]}?token=#{current_user.token}"
    else
      redirect_to new_user_session_path(redirect_path: params[:redirect_path])
    end
  end

  def sign_in_from_hostdomain
    redirect_to "#{ENV['OSEM_HOSTNAME']}/signed_in_user?redirect_path=#{request.referer}"
  end

  private

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :biography, :nickname, :affiliation)
    end
end
