class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  def claim(uuid)
    Element.unclaimed.uuid(uuid).update_all(discovered_by: self)
    Recipe.unclaimed.uuid(uuid).update_all(discovered_by: self)
  end
end
