class Message < ActiveRecord::Base

	belongs_to :channel
	belongs_to :author, :class_name => "User"

	EXPORT_OPTIONS  = { :only => [:message, :created_at], :include => { :author => { :only => [:nickname, :email]} } }
end
