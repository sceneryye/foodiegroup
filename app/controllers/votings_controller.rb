class VotingsController < ApplicationController
  before_action :select_voting
  before_action :validate_user!
  before_action :autheorize_admin!, only: [:create, :eitd, :update, :new, :destroy]
  
  def new
  end

  def create
    ids = params[:ids].split(',')
    if ids.blank?
      return render json: {msg: 'no items were selected!'}
    elsif params[:end_time].blank?
      return render json: {msg: 'no endtime were selected!'}
    end
    
    voting = Voting.new end_time: params[:end_time]
    voting.name = params[:name] || 'No. ' + Voting.count.to_s
    if voting.save
      ids.each do |id|
        Vote.create vote_product_id: id, voting_id: voting.id
      end
      render json: {msg: 'ok', id: voting.id}
    else
      render json: {msg: 'Failed to create voting'}
    end
  end

  def vote_for_voting
    product_id = params[:product_id]
    voting_id = params[:voting_id]
    return render json: {msg: 'Please vote for one product!'} if product_id.blank?
    voting = Voting.find_by(id: voting_id)
    begin
      if current_user.in? voting.users
        render json: {msg: 'You have voted for this already!'}
      else
       voting.users << current_user
       vote_product = Vote.find_by(vote_product_id: product_id, voting_id: voting_id)
       Rails.logger.info vote_product
       votes = vote_product.votes + 1
       vote_product.update(votes: votes)
       data_hash = {}
       voting.vote_products.each do |product|
        data_hash["#{product.id}"] = Vote.find_by(vote_product_id: product.id, voting_id: voting_id).votes
      end
      all_votes = voting.votes.pluck(:votes).inject(0, :+)
      Rails.logger.info data_hash
      render json: {msg: 'ok', data: data_hash, all_votes: all_votes}
    end
    rescue Exception => e
      msg = e.message
      render json: {msg: e.message}
    end
  end

  def edit
  end

  def update
  end

  def destroy
    @voting.delete
    redirect_to my_votings_path
  end

  def show
    @vote_products = @voting.vote_products
    @all_votes = @voting.votes.pluck(:votes).inject(0, :+)
    Rails.logger.info @all_votes
    if current_user
      @show_result = current_user.votings.include?(@voting) || Time.current > @voting.end_time
    end
    #微信share接口配置
      if session[:locale] == 'en'
        @title = 'Vote Now!'
      else
        @title = '本周投票'
      end
    @img_url = 'http://foodie.trade-v.com/votenow.jpg'
    @desc = 'The most voted will become the next hot deal!'
    share_config
  end

  def index
  end

  private
  def select_voting
    @voting = Voting.find_by(id: params[:id])
  end
end
