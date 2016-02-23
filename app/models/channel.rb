class Channel < ActiveRecord::Base

	has_many :messages

	belongs_to :creator, :class_name => "User"

	has_and_belongs_to_many :participants, :class_name => "User"


	EXPORT_OPTIONS = { :only => [:name, :last_message_at], :include => { :creator => { :only => [:nickname, :email]} } }
	EXPORT_OPTIONS_WITH_PARTICIPANTS = { 
		:only => [:name, :last_message_at], 
		:include => { 
			:creator => { 
				:only => [:nickname, :email]
			},
			:participants => {
				:only => [:nickname, :email]
			}
		} 
	}
end
