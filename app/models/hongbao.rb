class Hongbao < ActiveRecord::Base
  belongs_to :user
  belongs_to :participant


  	def status_text
	  	return 'sent'  if status == 1
	  	return 'unsent'  if status == 0
	end
end