class User < ActiveRecord::Base
  has_many :microposts, dependent: :destroy
  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
  has_many :followed_users, through: :relationships, source: :followed
  has_many :reverse_relationships, foreign_key: "followed_id",
                                   class_name:  "Relationship",
                                   dependent:   :destroy
  has_many :followers, through: :reverse_relationships, source: :follower
  before_save { email.downcase! }
  before_create :create_remember_token

  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(?:\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }

  has_secure_password
  validates :password,  presence: true,
                        confirmation: true,
                        length: { minimum: 6 },
                        :unless => :disable_validation
  validates :username, presence: true, uniqueness: { case_sensitive: false }

  state_machine :state, :initial => :inactive do
    state :active
    event :activate do
      transition :inactive => :active
    end

  end

  def User.new_remember_token
    SecureRandom.urlsafe_base64
  end

  def User.digest(token)
    Digest::SHA1.hexdigest(token.to_s)
  end

  def User.search(search)
    if search
      where('name LIKE ?', "%#{search}%")
    else
      all
    end
  end

  def feed
    Micropost.from_users_followed_by(self)
  end

  def following?(other_user)
    relationships.find_by(followed_id: other_user.id)
  end

  def follow!(other_user)
    UserMailer.follow_notification(other_user, self).deliver if other_user.notification?
    relationships.create!(followed_id: other_user.id)
  end

  def unfollow!(other_user)
    relationships.find_by(followed_id: other_user.id).destroy
  end

  def disable_validation
    @disable_validation
  end

  def disable_validation=(value)
    @disable_validation = value
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save(validate: false)
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  private

    def create_remember_token
      self.remember_token = User.digest(User.new_remember_token)
    end

    def password_is_not_being_updated?
      self.id && self.password.blank?
    end
end
