class VoteProductsController < ApplicationController
  before_action :autheorize_admin!
  def new
    @product = VoteProduct.new
  end

  def create
    uploaded_io = vote_product_params[:picture]
    if uploaded_io.present?
      extension = uploaded_io.original_filename.split('.')
      filename = "#{Time.now.strftime('%Y%m%d%H%M%S%L')}#{rand(100)}.#{extension[-1]}"
      filepath = "#{PIC_PATH}/vote_products/#{filename}"
      localpath = "#{Rails.root}/public/#{filename}"
      content_type = uploaded_io.content_type
      file = File.open(filepath, 'wb') do |file|
       file.write(uploaded_io.read)
     end
     path = "#{PIC_PATH}/vote_products"
     resize filename, 'mini', 300, 300, path
     VoteProduct.create title: vote_product_params[:title], picture: ('/vote_products/mini/' + filename)
     redirect_to vote_products_path
   else
    render 'new'
  end
end

def index
  @products = VoteProduct.all.order(created_at: :desc)
end

def destroy
  product = VoteProduct.find_by(id: params[:id])
  @id = product.id
  img_mini_url = "#{PIC_PATH}#{product.picture}"
  img_url = img_mini_url.sub('/mini', '')
  product.destroy
  `rm "#{img_mini_url}"`
  `rm "#{img_url}"`
  respond_to do |format|
    format.html {redirect_to vote_products_path}
    format.js
  end
end



private
def vote_product_params
  params.require(:vote_product).permit(:title, :picture)
end
end
