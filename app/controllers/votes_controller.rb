class VotesController < ApplicationController
  def create
    vote = Vote.new vote_params
    if vote.save
      vote_params.each do |key, value|
        if vote_params[key].present? && key.to_s != 'status'
          obj = key.to_s.capitalize.find(value)
          if vote_params[:status] == 1
            obj.update(:agree, obj.agree + 1)
          elsif vote_params[:status] == -1
            obj.update(:disagree, obj.agree + 1)
          end
        end
      end
    end
  end

  def destroy
  end

  private
  def vote_params
    params.require(:vote).permit(:status, :user_id, :topic_id, :event_id, :comment_id)
  end
end
