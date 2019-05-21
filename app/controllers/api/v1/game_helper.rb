module Api
  module V1
    class GameHelper
      def initialize(status)
        @spots = status.split(",")
        @last_spot = 0
      end

      def update(spot, val)
        if spot > 8 || spot < 0 || @spots[spot] != "-"
          false
        else
          @spots[spot] = val
          @last_spot = spot
          true
        end
      end

      def get_state
        @spots.join(",")
      end

      def has_finished?
        !@spots.include? "-"
      end

      def has_winner?
        if [0,2,6,8].include? @last_spot && @spots[@last_spot] != "-"
          return true if @spots.values_at(0,4,8).uniq.length == 1
          return true if @spots.values_at(2,4,6).uniq.length == 1
        end
        check_row || check_column
      end

      private
      def check_row
        row = @last_spot / 3
        spots = [0, 1, 2].map {|e| e + row * 3}
        @spots.values_at(*spots).uniq.length == 1
      end

      def check_column
        col = @last_spot % 3
        spots = [0, 3, 6].map {|e| e + col}
        @spots.values_at(*spots).uniq.length == 1
      end
    end
  end
end
