class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :validatable

  alias_method :authenticate, :valid_password?

  def self.from_token_payload(payload)
    self.find payload['sub']
  end

  def to_token_payload
    {:sub => self.id, :email => self.email}
  end
end
