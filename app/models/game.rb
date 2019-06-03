class Game < ApplicationRecord
  belongs_to :host, class_name: "User"
  belongs_to :guest, class_name: "User", optional: true

  scope :participating, ->(id) { where("host_id = ?  OR guest_id = ?", id, id).includes(:host, :guest)}

  scope :available, ->(id) do
    where("finished IS FALSE").where(
      "host_id = ? OR guest_id = ? OR guest_id IS NULL", id, id
    ).includes(:host, :guest)
  end

  scope :turn_of, ->(id) { where("next_player = ? AND winner IS NULL", id)}
  scope :can_participate, ->(id) { where("host_id != ? AND guest_id IS NULL", id).includes(:host, :guest).lock(true)}

  def play(spot, payload)
    tic = GameHelper.new self.state
    if !tic.update(spot, payload)
      return false
    end
    self.state = tic.get_state
    if tic.has_winner?
      self.winner = self.next_player
      self.finished = true
    else
      self.finished = true if tic.has_finished?
    end
    self.next_player = self.next_player == self.host_id ? self.guest_id : self.host_id
    true
  end

  def participate(id)
    self.guest_id = id
    self.next_player = id
  end
end
