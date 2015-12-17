class TagsController < ApplicationController
  def create
  end

  def update
    tag = Tag.find(params[:id])
    if tag.update(name: params[:name], url: params[:url], locale: params[:locale])
      render text: 'success'
    else
      render text: 'fail'
    end
  end

  def destroy
    tag = Tag.find(params[:id])
    if tag.destroy
      render text: 'success'
    else
      render text: 'fail'
    end
  end
end
