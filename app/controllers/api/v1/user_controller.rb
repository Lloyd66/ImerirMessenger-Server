class Api::V1::UserController < ApplicationController

	before_filter :authentify, :only => [:update]

	def authentify
		token = Token.includes(:user).find_by_value(params[:token])

		if(token.nil?)
			render json: { 
				success: false , 
				reason: "Invalid token", 
				errno: -4
			}, callback: params[:callback]
			return false
		else
			if(token.expires_at>Time.zone.now)
				@user = token.user
				return true
			else
				token.destroy

				render json: { 
				success: false , 
				reason: "Token expired", 
				errno: -5
			}, callback: params[:callback]
			end
		end
	end

	def create
		userParams = params.require(:user).permit([:nickname, :email, :password])

		userMail = User.find_by_email(userParams[:email])

		if(userMail.nil?)
			userParams[:password] = Digest::MD5.hexdigest(userParams[:password])
			user = User.new userParams
			user.save
			render json: { success: true}, :status => 200, callback: params[:callback]
		else
			render json: { success: false, reason: "User already exists", errno: -1 }, callback: params[:callback]
		end
	end

	def connect
		userParams = params[:user]

		user = User.find_by_email(userParams[:email])

		if(!user.nil?)
			password = Digest::MD5.hexdigest(userParams[:password])

			if(user.password.eql?(password))
				#User credentials are correct, now we generate a token which will be used for every other api call
				token = Token.new
				token.value = Digest::MD5.hexdigest(password+Digest::SHA256.hexdigest(Time.zone.now.to_s))
				token.expires_at = Time.zone.now+30.days
				token.user = user
				token.save
				render json: { success: true, :token => token.as_json({:only => [:value, :expires_at]})}, callback: params[:callback]
			else
				render json: { success: false, reason: "Invalid password", errno: -3 }, callback: params[:callback]
			end
		else
			render json: { success: false, reason: "User not found", errno: -2 }, callback: params[:callback]
		end
	end

	def update
		userParams = params.require(:user).permit(:nickname)
		@user.update_attributes(userParams)

		render json: { success: true}, callback: params[:callback]
	end
end
