class Hongbao < ActiveRecord::Base
  belongs_to :user
  belongs_to :participant


  	def status_text
	  	return 'Paid'  if status == 1
	  	return 'Unpaid'  if status == 0
	  	#return 'order unpaid'  if self.participant.status_pay == 0
	end
end