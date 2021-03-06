class User < ApplicationRecord
  has_many :follower_relationships, foreign_key: :following_id, class_name: 'Follow'
  has_many :followers, through: :follower_relationships, source: :follower

  has_many :following_relationships, foreign_key: :follower_id, class_name: 'Follow'
  has_many :following, through: :following_relationships, source: :following
  has_many :miniposts, dependent: :destroy
  validates_uniqueness_of :username
  mount_uploader :avatar, AvatarUploader
  mount_uploader :cover, CoverUploader

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable
  def to_param
    username
  end

  def follow(user_id)
    following_relationships.create(following_id: user_id)
  end

  def unfollow(user_id)
    following_relationships.find_by(following_id: user_id).destroy
  end

  def is_following?(user_id)
    relationship = Follow.find_by(follower_id: id, following_id: user_id)
    return true if relationship
  end

  def feed
    following_ids = "SELECT following_id FROM follows
                     WHERE  follower_id = :user_id"
    Minipost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end
end
