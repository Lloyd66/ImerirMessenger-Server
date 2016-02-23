class Api::V1::MessageController < ApplicationController

	before_filter	:authentify
	before_filter :get_channel

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

	def get_channel
		id = params[:channel_id]
		@channel = @user.channels.find_by_name(id)

		if(@channel.nil?)
			render json: { 
				success: false , 
				reason: "Channel doesn't exist", 
				errno: -6
			}, callback: params[:callback]
			return false
		else
			return true
		end

	end

	def index
		render json: { 
				success: true , 
				messages: @channel.messages.order("created_at desc").limit(50).as_json(Message::EXPORT_OPTIONS)
			}, callback: params[:callback]
	end

	def create
		message = Message.new 
		message.author = @user
		message.message = params[:message]
		message.channel = @channel
		message.save

		@channel.last_message_at = Time.zone.now
		@channel.save

		render json: Oj.dump({ 
			:success => true
		}, mode: :compat), callback: params[:callback]
	end
end
