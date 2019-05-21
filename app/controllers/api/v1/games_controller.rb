module Api
  module V1
    class GamesController < Api::V1::BaseApiController

      def index
        games = Game.where("finished IS FALSE")
        games = games.where("host_id = ? OR guest_id = ? OR guest_id IS NULL", current_user.id, current_user.id).includes(:host, :guest)
        games_array = games.map do |game|
          {id: game.id, state: game.state, host: game.host, guest: game.guest, next_player: game.next_player, winner: game.winner, finished: game.finished}
        end
        render :json => {games: games_array}
      end

      def show
        game = Game.where("id = ? AND (host_id = ?  OR guest_id = ?)", params[:id], current_user.id, current_user.id).includes(:host, :guest).take
        if !game
          render status: :not_found
        else
          render :json => {
            game: {
              id: game.id,
              host: game.host,
              guest: game.guest,
              next_player: game.next_player,
              winner: game.winner,
              state: game.state,
              finished: game.finished
            }
          }
        end
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

      def update
        spot = permit_spot[:spot].to_i
        game = Game.where(
          "id = ? AND next_player = ? AND winner IS NULL",
          params[:id],
          current_user.id
        ).includes(:host, :guest).take
        if !game
          render status: :not_found
        else
          tic = GameHelper.new game.state
          if !tic.update spot, game.next_player == game.host_id ? "O" : "X"
            return render status: :unprocessable_entity
          end
          game.state = tic.get_state
          if tic.has_winner?
            game.winner = game.next_player
            game.finished = true
          else
            game.finished = true if tic.has_finished?
          end
          game.next_player = game.next_player == game.host_id ? game.guest_id : game.host_id

          if game.save
            render :json => {
                game: {
                id: game.id,
                host: game.host,
                guest: game.guest,
                next_player: game.next_player,
                winner: game.winner,
                state: game.state,
                finished: game.finished
              }
            }
          else
            render status: :internal_error
          end
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

      private
      def permit_spot
        params.permit(:spot)
      end
    end
  end
end
