class Micropost < ActiveRecord::Base
  belongs_to :user
  default_scope -> { order('created_at DESC') }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  REPLY_REGEX = /\A@(?<uname>[^\s]+)/
  DIRECT_REGEX = /\Ad @(?<uname>[^\s]+)/


  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id OR in_reply_to = :username",
          user_id: user.id, username: user.username)
  end

  def reply_to?
    content.start_with?('@')
  end

  def direct_message?
    content.start_with?('d @') && recipient
  end

  def reply_to
    REPLY_REGEX.match(content)[:uname] if reply_to?
  end

  def direct_message_hash
    body = content.split(DIRECT_REGEX).last
    { :content => body, :sender_id => self.user_id,
      :recipient_id => recipient.id }
  end

  private

    def recipient
      @recipient ||= User.find_by_username(recipient_username)
    end

    def recipient_username
      DIRECT_REGEX.match(content)[:uname]
    end
end
