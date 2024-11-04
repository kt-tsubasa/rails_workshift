class UsersController < ApplicationController
    
    def show
        @user = User.find(params[:id])
    end

    def update
        @user = User.find(params[:id])
        if @user.update(user_params)
            redirect_to @user, notice: `Profile updated successfully.`
        else
            render :show
        end
    end

    private

    def user_params
        params.require(:user).permit(:email, :name, :profile, :profile_image)
    end
end
