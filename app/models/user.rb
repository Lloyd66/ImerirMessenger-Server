class User < ActiveRecord::Base

	has_many :tokens
	
	has_and_belongs_to_many :channels
end
