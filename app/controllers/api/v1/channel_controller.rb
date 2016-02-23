class Api::V1::ChannelController < ApplicationController

	before_filter	:authentify

	before_filter :get_channel, :only => [:show, :update, :destroy, :quit]

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
		id = params[:id]
		if(id.nil?)
			id = params[:channel_id]
		end
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
		mine = (!params[:mine].nil? and params[:mine].eql?("true"))
		channels = []
		if(mine)
			channels = @user.channels.includes(:creator).order("last_message_at desc").as_json(Channel::EXPORT_OPTIONS)
		else
			channels = Channel.where(:is_direct_message_channel => false).includes(:creator).order("last_message_at desc").as_json(Channel::EXPORT_OPTIONS)
		end

		render json: Oj.dump({ 
			:success => true, 
			:channels => channels
		}, mode: :compat), callback: params[:callback]
	end

	def create

		channelParams = params.require(:channel).permit([:name])

		channelTest = Channel.find_by_name(channelParams[:name])

		if(channelTest.nil?)
			channel = Channel.new channelParams
			channel.creator = @user
			channel.is_direct_message_channel = false
			channel.save

			@user.channels << channel

			render json: Oj.dump({ 
				:success => true, 
				:channel => channel.as_json(Channel::EXPORT_OPTIONS)
			}, mode: :compat), callback: params[:callback]
		else
			render json: Oj.dump({ 
				:success => false, 
				reason: "Channel already exists", 
				errno: -8
			}, mode: :compat), callback: params[:callback]
		end
	end

	def update
		channelParams = params.require(:channel).permit([:name])
		@channel.update_attributes(channelParams)

		render json: Oj.dump({ 
			:success => true, 
			:channel => @channel.as_json(Channel::EXPORT_OPTIONS)
		}, mode: :compat), callback: params[:callback]
	end

	def show
		render json: Oj.dump({ 
			:success => true, 
			:channel => @channel.as_json(Channel::EXPORT_OPTIONS_WITH_PARTICIPANTS)
		}, mode: :compat), callback: params[:callback]
	end

	def join
		@channel = Channel.where.not(:is_direct_message_channel => true).find_by_name(params[:channel_id])

		puts "channel -> "+@channel.to_s
		unless(@channel.nil?)
			if(!@user.channels.include?(@channel))
				message = Message.new 
				visibleName = @user.nickname.empty? ? @user.email : @user.email
				message.message = visibleName+" a rejoint le canal "+@channel.name
				message.channel = @channel
				message.save
				@user.channels << @channel
			end
			render json: Oj.dump({ 
			:success => true, 
			:channel => @channel.as_json(Channel::EXPORT_OPTIONS_WITH_PARTICIPANTS)
		}, mode: :compat), callback: params[:callback]
		else
			render json: { 
				success: false , 
				reason: "Channel doesn't exist", 
				errno: -6
			}, callback: params[:callback]
		end
	end

	def quit
		unless(@channel.nil?)
			if(@user.channels.include?(@channel))
				message = Message.new 
				visibleName = @user.nickname.empty? ? @user.email : @user.email
				message.message = visibleName+" a quitté le canal "+@channel.name
				message.channel = @channel
				message.save
				@user.channels.delete(@channel)
			end
			render json: Oj.dump({ 
			:success => true,
			:status => "deleted"
		}, mode: :compat), callback: params[:callback]
		else
			render json: { 
				success: false , 
				reason: "Channel doesn't exist", 
				errno: -6
			}, callback: params[:callback]
		end
	end

	def destroy
		if(@channel.creator_id==@user.id)
			@channel.destroy
			render json: Oj.dump({ 
				:success => true, 
				:status => "deleted"
			}, mode: :compat), callback: params[:callback]
		else
			render json: Oj.dump({ 
				:success => false, 
				reason: "Only the channel's owner can delete it", 
				errno: -7
			}, mode: :compat), callback: params[:callback]
		end
	end
end
