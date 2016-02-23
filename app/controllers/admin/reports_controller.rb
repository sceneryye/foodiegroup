class Admin::ReportsController < ApplicationController
      skip_before_filter :require_permission!
      skip_before_filter :verify_authenticity_token,:only=>[:batch]

  before_action :autheorize_admin!
  layout 'admin'
  def index
    @users = User.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def users_list
    @users = User.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def groupbuys_list
    @groupbuys = Groupbuy.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def topics_list
    @topics = Topic.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def participants_list
    @groupbuy = Groupbuy.find(params[:groupbuy_id])
    @participants = Participant.unscoped {Participant.where(:groupbuy_id => params[:groupbuy_id]).paginate(per_page: 100, page: params[:page]).order(status_pay: :desc)}
  end

  def tags_list
    @tags = Tag.all.order(locale: :asc)
  end

  def downorder

         orders= Ecstore::participants.where(@participants.groupbuy_id)
   
          package = Axlsx::Package.new
          workbook = package.workbook

            workbook.styles do |s|
          head_cell = s.add_style  :b=>true, :sz => 10, :alignment => { :horizontal => :center,
                                                                        :vertical => :center}
          employees_cell = s.add_style :b=>true,:bg_color=>"FFFACD", :sz => 10, :alignment => {:vertical => :center}

          workbook.add_worksheet(:name => "ordersinfo") do |sheet|

          sheet.add_row ["姓名","联系电话","地址","数量","单价","总价","付款状态","发货状态","报名时间"],:style=>head_cell
                     
                
            row_count=0

            orders.each do |order| 
              orderid=order.name.to_s + " "
              memberid=order.mobile
              shipname=order.address
              createdat=order.quantity
              statustext=order.groupbuy.price
              paystatustext=order.amount * order.groupbuy.price
              shipstatustext=status_pay
              finalamount=order.final_amount
              shopid=order.status_ship
             shipaddrs=order.created_at
          
              sheet.add_row [orderid,memberid,shipname,createdat,statustext,paystatustext,shipstatustext,finalamount,shopid,shipaddrs]
              row_count +=1
            end

           end
          send_data package.to_stream.read,:filename=>"order_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
          end
      end
end
