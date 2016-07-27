class User < ActiveRecord::Base
  has_secure_password
  # validates :weixin_openid, uniqueness: true
  has_many :favorites, dependent: :destroy
  has_many :topics,   dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :groupbuys, dependent: :destroy
  has_many :user_interests, dependent: :destroy
  has_many :user_addresses, dependent: :destroy
  has_many :logistics, dependent: :destroy
  has_and_belongs_to_many :votings
  has_many :wishlists, dependent: :destroy
  has_many :downpayments, dependent: :destroy
  has_many :shops, dependent: :destroy
  has_many :hongbaos
  belongs_to :group


  #validates :username,   presence:   true,
  #uniqueness: { case_sensitive: false },
  #length:     { in: 2..40 }
                         #,format:     { with: /\A[a-zA-Z][a-zA-Z0-9_-]*\Z/ }
                        # ,exclusion:  { in: ['oturum_ac'] }

                        #validates :mobile,    presence:   true,
                        #uniqueness: { case_sensitive: false }

  # validates :email,      presence:   true,
  #                        uniqueness: { case_sensitive: false },
  #                        email:      true

  #validates :terms_of_service, acceptance: { accept: 'yes' }


  def to_param
    username
  end

  def default_address
    self.user_addresses.where(default: 1).first || self.user_addresses.first
  end
end
