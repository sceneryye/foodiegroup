class AdminsController < ApplicationController
  before_action :autheorize_admin!
  layout 'admin'
  def index
   redirect_to users_list_admins_path
  end

  def send_bonus
    if params[:order_id].present?
      share = Ecstore::WeihuoShare.where(:order_id => params[:order_id]).first
      if share.status != 0
        return render :text => {:status => share.status}.to_json
      end
    end
    supplier = Ecstore::Supplier.where(:name => '贸威').first

    arr = ('0'..'9').to_a + ('a'..'z').to_a
    nonce_str = ''
    32.times do
      nonce_str += arr[rand(36)].upcase
    end

    re_openid = params[:re_openid]
    total_amount = params[:total_amount].present? ? params[:total_amount].to_i * 100 : ''
    weixin_appid = supplier.weixin_appid
    weixin_appsecret = supplier.weixin_appsecret
    key = Ecstore::Supplier.where(:name => '贸威').first.partner_key
    mch_id = supplier.mch_id
    mch_billno = mch_id + Time.zone.now.strftime('%F').split('-').join + rand(10000000000).to_s.rjust(10, '0')

    parameter = {
      :nonce_str => nonce_str, :mch_billno => mch_billno, :mch_id => mch_id, :wxappid => weixin_appid, :send_name =>'尾货良品老板',
      :re_openid => re_openid, :total_amount => total_amount, :total_num => 1, :wishing => params[:wishing],
      :client_ip => '182.254.138.119', :act_name => params[:act_name], :remark => params[:remark]
    }

    stringA = parameter.select{|key, value|value.present?}.sort.map do |arr|
      arr.map(&:to_s).join('=')
    end

    stringA = stringA.join("&")
    #return render :text => stringA
    @b = string_sing_temp = stringA + "&key=#{key}"

    sign = (Digest::MD5.hexdigest string_sing_temp).upcase
    parameter[:sign] = sign
    parameter


    params_str = ''
    parameter.each do |key, value|
     params_str += "<#{key}>" + "<![CDATA[#{value}]]>" + "</#{key}>"
   end
   @a = params_xml = '<xml>' + params_str + '</xml>'

    #url = 'https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack'

    uri = URI.parse('https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack')

    cert = File.read("#{ Rails.root }/lib/maowei_cert/apiclient_cert.pem")

    key = File.read("#{ Rails.root }/lib/maowei_cert/apiclient_key.pem")

    http = Net::HTTP.new(uri.host, uri.port)

    http.use_ssl = true if uri.scheme == 'https'

    http.cert = OpenSSL::X509::Certificate.new(cert)

    http.key = OpenSSL::PKey::RSA.new(key, '商户编号')

    http.ca_file = File.join("#{ Rails.root }/lib/maowei_cert/rootca.pem")

    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    res_data = ''

    http.start { http.request_post(uri.path, params_xml) { |res| res_data = res.body } }
    @res_data_hash = Hash.from_xml res_data
    if params[:from] == 'weihuo_shares'
      return render :text => @res_data_hash['xml'].to_json
    elsif params[:from] == 'auto_send_bonus'
      return render :text => @res_data_hash['xml']
    end
    render 'send_bonus'
  end


  def edit_user
    @user = User.find(params[:id])
  end

  def update_user
    @user = User.find(params[:id])
    @user.update_attributes(user_params)
    @user.save!
    redirect_to users_list_admins_path, notice: '会员信息修改成功'
  end

  def users_list
    @users = User.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def hongbaos_list
    @hongbaos = Hongbao.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def groupbuys_list
    @groupbuys = Groupbuy.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def topics_list
    @topics = Topic.paginate(per_page: 20, page: params[:page]).order(id: :asc)
  end

  def participants_list
    @groupbuy = Groupbuy.find(params[:groupbuy_id])
    @participants = Participant.unscoped {Participant.where(:groupbuy_id => params[:groupbuy_id]).paginate(per_page: 100, page: params[:page]).order(created_at: :desc)}
  end

  def tags_list
    @tags = Tag.all.order(locale: :asc)
  end

  def set_online_offline
    @groupbuy = Groupbuy.find_by(id: params[:id])
    if params[:online] == 'true'
      @groupbuy.update!(online: true)
    elsif params[:online] == 'false'
      @groupbuy.update!(online: false)
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

  private 
  def user_params

    params.require(:user).permit(:role,:kol,
                        groupbuys_attributes: [:id])
  end
end
