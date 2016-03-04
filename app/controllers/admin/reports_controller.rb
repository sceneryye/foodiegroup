class Admin::ReportsController < ApplicationController
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

  def set_online_offline
    @groupbuy = Groupbuy.find_by(id: params[:id])
    if params[:online] == 'true'
      @groupbuy.update(online: true)
    elsif params[:online] == 'false'
      @groupbuy.update(online: false)
    end
    render json: {online: @groupbuy.online.to_s}.to_json
  end
   def downorder

          fields=params[:fields]
        @status_pay=params[:status_pay]


        @participants=Participant.where(:groupbuy_id => params[:groupbuy_id],:status_pay => params[:member][:status_pay])

          package = Axlsx::Package.new
          workbook = package.workbook

            workbook.styles do |s|
          head_cell = s.add_style  :b=>true, :sz => 10, :alignment => { :horizontal => :center,
                                                                        :vertical => :center}
          employees_cell = s.add_style :b=>true,:bg_color=>"FFFACD", :sz => 10, :alignment => {:vertical => :center}

        workbook.add_worksheet(:name => "Groupbuy") do |sheet|

          sheet.add_row ["姓名","联系电话","地址","数量",fields[0],fields[1],fields[2]],:style=>head_cell
                     
                
            row_count=0
            @participants.each do |p| 
        if p.mobile.length == 11 
              orderid=p.name.to_s + " "
              memberid=p.mobile
              shipname=p.address
              createdat=p.quantity
              
             shipstatustext=p.status_pay ==1 ? "已付款" : "未付款"
            
              shopid=p.status_ship ==0 ? "未发货" : "已发货"
             shipaddrs=p.created_at

                v =[]
                fields.each do |field|
                  if field=="付款状态"
                    v.push(p.status_pay ==1 ? "已付款" : "未付款")
                  end

                  if field=="发货状态"
                    v.push(p.status_ship ==0 ? "未发货" : "已发货")
                  end
                  if field=="报名时间"
                    v.push(p.created_at)
                  end
              
                end
              
              sheet.add_row [orderid,memberid,shipname,createdat,v[0],v[1],v[2]]
              end
              row_count +=1
            end

           end
          send_data package.to_stream.read,:filename=>"吃货帮订单_#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.xlsx"
          end
      end
end
