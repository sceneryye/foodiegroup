class TagsController < ApplicationController
  def create
    if params[:tag].nil?
      tag = Tag.new(tag_ajax_params)
      if tag.save
        id = tag.id
        render text: id
      else
        render text: 'fail'
      end
    end
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

  private
  def tag_params
    params.require(:tag).permit(:url, :name, :locale)
  end

  def tag_ajax_params
    params.permit(:url, :name, :locale)
  end
end
