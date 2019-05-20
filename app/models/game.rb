class Game < ApplicationRecord
  belongs_to :host, class_name: "User"
  belongs_to :guest, class_name: "User", optional: true
end
