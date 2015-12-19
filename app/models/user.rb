class User < ActiveRecord::Base
  has_secure_password

  has_many :topics,   dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :participants, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :groupbuys, dependent: :destroy
  has_many :user_interests, dependent: :destroy

  belongs_to :group


  validates :username,   presence:   true,
                         uniqueness: { case_sensitive: false },
                         length:     { in: 2..40 }
                         #,format:     { with: /\A[a-zA-Z][a-zA-Z0-9_-]*\Z/ }
                        # ,exclusion:  { in: ['oturum_ac'] }

  validates :mobile,    presence:   true,
                        uniqueness: { case_sensitive: false }

  # validates :email,      presence:   true,
  #                        uniqueness: { case_sensitive: false },
  #                        email:      true

  #validates :terms_of_service, acceptance: { accept: 'yes' }

 
  def to_param
    username
  end

 
end
