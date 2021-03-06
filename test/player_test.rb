require 'test_helper'

module Rubygoal
  class PlayerTest < Minitest::Test
    def setup
      @game = Rubygoal.game_instance
      home_team = @game.field.team_home

      @player = home_team.players.first
      @player.send(:time_to_kick_again=, 0)
    end

    def test_player_can_kick_the_ball_in_the_same_position
      position = Position.new(100, 100)
      @game.ball.position = position
      @player.position = position

      assert @player.can_kick?(@game.ball)
    end

    def test_player_can_kick_the_ball_when_is_close
      @game.ball.position = Position.new(100, 100)
      @player.position = Position.new(110, 115)

      assert @player.can_kick?(@game.ball)
    end

    def test_player_can_not_kick_the_ball_when_is_far
      @game.ball.position = Position.new(100, 100)
      @player.position = Position.new(200, 200)

      refute @player.can_kick?(@game.ball)
    end

    def test_player_can_not_kick_the_ball_again
      position = Position.new(100, 100)
      @game.ball.position = position
      @player.position = position

      @player.kick(@game.ball, Position.new(300, 300))

      refute @player.can_kick?(@game.ball)
    end

    def test_player_can_kick_the_ball_again_after_time
      position = Position.new(100, 100)
      @game.ball.position = position
      @player.position = position

      @player.kick(@game.ball, Position.new(300, 300))
      ticks = Rubygoal.configuration.kick_again_delay
      ticks.times { @player.update }

      assert @player.can_kick?(@game.ball)
    end

    def test_kick_the_ball_to_a_different_place
      position = Position.new(100, 100)
      @game.ball.position = position
      @game.ball.velocity = Velocity.new(0, 0)
      @player.position = position

      @player.kick(@game.ball, Position.new(300, 300))

      refute_equal Velocity.new(0, 0), @game.ball.velocity
    end

    def test_kick_direction_range_right
      # Set little error: < 2 degrees (180 * 0.01 < 2)
      @player.instance_variable_set(:@error, 0.01)

      position = Position.new(100, 100)
      @game.ball.position = position
      @game.ball.velocity = Velocity.new(0, 0)
      @player.position = position

      # 90 degree kick
      @player.kick(@game.ball, Position.new(200, 100))

      velocity = @game.ball.velocity
      velocity_angle = Gosu.angle(0, 0, velocity.x, velocity.y)

      assert_in_delta 90, velocity_angle, 2
    end

    def test_kick_direction_range_left
      # Set little error: < 2 degrees (180 * 0.01 < 2)
      @player.instance_variable_set(:@error, 0.01)

      position = Position.new(100, 100)
      @game.ball.position = position
      @game.ball.velocity = Velocity.new(0, 0)
      @player.position = position

      # 270 degree kick
      @player.kick(@game.ball, Position.new(0, 100))

      velocity = @game.ball.velocity
      velocity_angle = Gosu.angle(0, 0, velocity.x, velocity.y)

      assert_in_delta 270, velocity_angle, 2
    end

    def test_kick_strength
      # Set little error: distance error = 1 (20 * 0.05 = 1)
      @player.instance_variable_set(:@error, 0.05)

      position = Position.new(100, 100)
      @game.ball.position = position
      @game.ball.velocity = Velocity.new(0, 0)
      @player.position = position

      @player.kick(@game.ball, Position.new(200, 200))

      velocity = @game.ball.velocity
      velocity_strength = Gosu.distance(0, 0, velocity.x, velocity.y)

      assert_in_delta 20, velocity_strength, 1
    end
  end
end
