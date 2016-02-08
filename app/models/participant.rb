class Participant < ActiveRecord::Base
	belongs_to :user
	belongs_to :event, counter_cache: true
	belongs_to :groupbuy, counter_cache: true

	validates :quantity,  presence: true
	validate :check_quantity

	default_scope {order 'created_at DESC'}

	def check_quantity
		
		count = 1
		if self.groupbuy_id
			count = self.groupbuy.goods_minimal
		end

		if self.quantity < count
			errors.add(:base, :greater_than_or_equal_to,:count=>count)
		end

	end

	before_create :initialize_attrs

	def initialize_attrs
	    #self.order_id = Participant.generate_order_id
	    # self.amount = 1
	    # self.status = 0
	    # # self.freightage = 0
	    # self.discount = 0
	    #self.currency = "CNY"

	    # if self.ship_day == 'special'
	    #   self.ship_time = "#{self.ship_special}#{self.ship_time2}"
	    # else
	    #   self.ship_time = "#{self.ship_day}#{self.ship_time2}"
	    # end
	  end

	before_save :get_address, :calculate_amount,:calculate_freightage, :calculate_discount #:calculate_itemnum

	def get_address
		address = self.user.default_address
		self.name = address.name
		self.address = address.address
		self.mobile = address.mobile
		self.area = address.area.split('/')[0]
	end

	def calculate_amount
	  #团购期间是团购价，非团购期间是市场价
	  if self.groupbuy_id.present?
	  	price = self.groupbuy.current_price
	  	self.amount = self.quantity.to_i * price
	  end
	end

	def calculate_freightage
		if self.groupbuy_id.present?
			if Groupbuy.find_by(id: self.groupbuy_id).logistic_id
				logistics_item = LogisticsItem.where("logistic_id = #{self.groupbuy.logistic_id} and areas like '%#{self.area}%' ")

				if logistics_item.size>0
					weight = self.quantity * self.groupbuy.weight
					self.freightage = logistics_item.first.price + (weight - 1 + BOX_WEIGHT).ceil * logistics_item.first.each_add
				else
					self.freightage = 0
				end
			else
				self.freightage = 0
			end
		end
	end

	def calculate_discount

		self.discount = 0
	end


	after_create  :adjust_store
	def adjust_store

		if self.groupbuy_id
			current_store = self.groupbuy.goods_maximal - self.quantity
			self.groupbuy.update(goods_maximal: current_store)
		end
	end


	#  around_update :finish_order

	def finish_order

		before_update_status = self.class.find_by_order_id(self.order_id).status
		yield
		after_update_status = self.status

	    # 完成订单
	    if before_update_status != 'finish' && after_update_status == 'finish'

	    	_order = self
	    	_user = self.user

	    	if %w(0 1 2).include?(self.ship_status)
	        # coupon promotions
	        order_pmts = _order.order_pmts.where(:pmt_type=>%w(goods order))
	        order_pmts.each do |order_pmt|
	        	pmt = order_pmt.promotion
	        	if pmt&&pmt.action_type == 'coupon'
	        		(pmt.action_val||[]).each do |coupon_id|
	        			coupon = Ecstore::NewCoupon.find_by_id(coupon_id)
	        			Ecstore::UserCoupon.create({
	        				:member_id => _user.member_id,
	        				:coupon_id=>coupon_id,
	        				:coupon_code=> coupon.generate_coupon_code(true)
	        				})
	        		end
	        	end
	        end
	      end

	      if _order.part_pay?
	      	advance = _user.advance
	      	advance_freeze = _user.advance_freeze

	        if %w(0 1 2).include?(self.ship_status)  # 发货时更新冻结预存款
	        	Ecstore::User.where(:member_id=>_user.member_id).update_all({ :advance_freeze=> advance_freeze - self.part_pay })
	        else # 退货时更新冻结预存款和预存款
	        	Ecstore::User.where(:member_id=>_user.member_id).update_all({ :advance_freeze=> advance_freeze - self.part_pay,:advance=>advance + self.part_pay })
	        end
	      end

	    end

	    # 作废订单
	    if before_update_status != 'finish' && after_update_status == 'dead'
	      # 已发货或者部分发货订单恢复库存
	      if %w(1 2).include?(self.ship_status)
	      	self.order_items.each do |order_item|
	      		if (_product = order_item.product) && order_item.sendnum > 0
	      			_product.update_attribute :freez, _product.freez - order_item.sendnum
	      			_product.update_attribute :store, _product.store + order_item.sendnum
	      		end
	      	end
	      end
	      # 已付款或部分付款恢复预存款
	      if %w(1 3).include?(self.pay_status) && self.part_pay?
	      	advance = self.user.advance
	      	advance_freeze =  self.user.advance_freeze
	      	Ecstore::User.where(:member_id=>self.member_id).update_all({ :advance_freeze=> advance_freeze - self.part_pay, :advance=>advance +  self.part_pay })
	      end

	    end

	  end


	  def self.generate_order_id
	  	seq = rand(0..9999)
	  	loop do
	  		seq = 1 if seq == 9999
	  		_order_id = Time.zone.now.strftime("%Y%m%d%H") + ( "%04d" % seq.to_s )
	  		return _order_id unless Participent.find_by_order_id(_order_id)
	  		seq += 1
	  	end
	  end


	  def products_total
	  	self.order_items.select{ |order_item| order_item.item_type == 'product' }.collect{ |order_item|  order_item.amount }.inject(:+).to_f
	  end

	  def pmts_total
	  	self.order_pmts.collect { |order_pmt| order_pmt.pmt_amount }.inject(:+).to_f
	  end

	  def total
	  	self.amount.to_f + self.freightage.to_f - self.discount.to_f
	  end

	  def payment_name
	  	return "微信支付" if payment == "wxpay"
	  	return "支付宝手机版" if payment == "alipaywap"
	  	return "支付宝PC版" if payment == "alipay"
	  	return "货到付款" if payment == "offline"
	  	return "无支付方式" if payment.blank?
	  end

	  def status_text
	  	return '活动订单 ' if status == '0'
	  	return '已作废' if status == '-1'
	  	return '已完成' if status == '1'
	  end

	  def serverinvoice_text
	  	return  '未选择发票' if serverinvoice=='0'
	  	return  '运费发票(总运费的11%)' if serverinvoice=='1'
	  	return  '服务费发票 (总运费的8%)' if serverinvoice=='2'
	  	return  '自带发票(总运费的1%)' if serverinvoice=='3'
	  end

	  def shipping
	  	return "快递" if self.shipping_id==1
	  	return "自提" if self.shipping_id==0
	  end

	  def pay_status_text
	  	return '未付款' if pay_status == '0'
	  	return '已付款' if pay_status == '1'
	  	return '付款至担保方' if pay_status == '2'
	  	return '部分付款' if pay_status == '3'
	  	return '部分退款' if pay_status == '4'
	  	return '已退款' if pay_status == '5'
	  end

	  def ship_status_text
	  	return '未发货'  if ship_status == '0'
	  	return '已发货' if ship_status == '1'
	  	return '部分发货' if ship_status == '2'
	  	return '部分退货' if ship_status == '3'
	  	return '已退货' if ship_status == '4'
	  end

	  def order_status_text
	  	return '已作废'  if status =='-1'
	  	return '已完成'  if status =='1'
	  	return '已发货'  if status == 'active' && ship_status == '1'
	  	return '已付款'  if status == 'active' && pay_status == '1'
	  	return '待付款'  if status == 'active' && pay_status == '0'
	  end

	  def progress_status
	  	return 'finish'  if status == 'finish'
	  	return 'dead' if status == 'dead'
	  	return 'shipping'  if ship_status == '1'
	  	return 'paid' if payment == 'offline'
	  	return 'paid'  if  pay_status == '1'
	  	return 'active'  if status == 'active'
	  	nil
	  end

	  def pay_type
	  	return 'offline' if self.payment == "offline"
	  	return 'deposit' if self.payment == 'deposit'
	  	return nil  if self.payment.blank?
	  	return "online"
	  end


	  def finished_at
	  	log = self.order_logs.where(:behavior=>'finish',:result=>"SUCCESS").first
	  	Time.at(log.alttime).strftime("%Y-%m-%d %H:%M:%S") if log
	  end


	  def paid_amount
	  	payments.where(:status=>"succ").sum(:money)
	  end

	  def refunded_amount
	  	refunds.where(:status=>"succ").sum(:money)
	  end


	  def self.export(orders=[],file="#{Rails.root}/public/tmp/orders.csv")

	  	CSV.open(file,"w:GB18030") do |csv|
	  		csv << [ "订单号(order_id)",
	  			"订单总额(final_amount)",
	  			"付款状态(pay_status)",
	  			"发货状态(ship_status)",
	  			"下单时间(createtime)",
	  			"支付方式(payment)",
	  			"会员用户名(member_id)",
	  			"订单状态(status)",
	  			"收货地区(ship_area)",
	  			"收货人(ship_name)",
	  			"收货地址(ship_addr)",
	  			"收货人电话(ship_tel)",
	  			"收货人手机(ship_mobile)"
	  		]
	  		orders.each do |order|
	  			csv << [ order.order_id,
	  				order.final_amount,
	  				order.pay_status_text,
	  				order.ship_status_text,
	  				order.created_at,
	  				order.payment_name,
	  				order.user.login_name,
	  				order.order_status_text,
	  				order.ship_area,
	  				order.ship_name,
	  				order.ship_addr,
	  				order.ship_tel,
	  				order.ship_mobile
	  			]
	  		end
	  	end

	  	file

	  end

	end
