module Api
  module V1
    class GamesController < Api::V1::BaseApiController

      def index
        games = Game.where("winner IS NULL")
        games = games.where("host_id = ? OR guest_id = ? OR guest_id IS NULL", current_user.id, current_user.id).includes(:host, :guest)
        games_array = games.map do |game|
          {id: game.id, state: game.state, host: game.host, guest: game.guest, next_player: game.next_player, winner: game.winner}
        end
        render :json => {games: games_array}
      end

      def create
        new_state = Array.new(9, '-').join(',')
        game = Game.new(host_id: current_user.id, state: new_state)
        if game.save
          render :json => {game: game}, :status => :created
        else
          render :json => {errors: game.errors}, :status => :internal_error
        end
      end

      def partecipate
        game = Game.where("id = ? AND host_id != ? AND guest_id IS NULL",params[:id], current_user.id).take
        if !game
          render status: :not_found
          return
        end
        if game.update(guest_id: current_user.id, next_player: current_user.id)
          render status: :ok
        else
          render status: :internal_error
        end
      end
    end
  end
end
