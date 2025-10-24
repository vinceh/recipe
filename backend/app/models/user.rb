class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  # Associations
  has_many :user_recipe_notes, dependent: :destroy
  has_many :user_favorites, dependent: :destroy
  has_many :favorite_recipes, through: :user_favorites, source: :recipe

  # Role enum (Rails 8 syntax)
  enum :role, { user: "user", admin: "admin" }
end
