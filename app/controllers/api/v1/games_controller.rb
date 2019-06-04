module Api
  module V1
    class GamesController < Api::V1::BaseApiController

      def index
        games = Game.available(current_user.id)
        render :json => {
          games: games.as_json(
            :include => {
              :host => {:only => [:email, :id]},
              :guest => {:only => [:email, :id]}
            },
            :except => [:host_id, :guest_id]
          )
        }
      end

      def show
        game = Game.participating(current_user.id).find(params[:id])
        render :json => serialize(game)
      end

      def create
        new_state = Array.new(9, '-').join(',')
        game = Game.new(host_id: current_user.id, state: new_state)
        if game.save
          render :json => serialize(game), :status => :created
        else
          render :json => {errors: game.errors}, :status => :internal_error
        end
      end

      def update
        param = permit_update
        if param.has_key?(:game) && param[:game].has_key?(:spot)
          game = Game.turn_of(current_user.id).find(params[:id])
          if !game.play(param[:game][:spot].to_i, game.next_player == game.host_id ? "O" : "X")
            return render status: :unprocessable_entity
          end
        else
          game = Game.can_participate(current_user.id).find(params[:id])
          game.participate(current_user.id)
        end

        if game.save
          render :json => serialize(game)
        else
          render status: :internal_error
        end
      end

      private
      def permit_update
        params.permit(:game => :spot)
      end

      def serialize(game)
        game.as_json(
            :include => {
              :host => {:only => [:email, :id]},
              :guest => {:only => [:email, :id]}
            },
            :except => [:host_id, :guest_id],
            :root => true
          )
      end
    end
  end
end
