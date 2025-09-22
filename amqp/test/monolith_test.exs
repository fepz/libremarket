defmodule MonolithTest do
  use ExUnit.Case
  doctest Monolith

  test "greets the world" do
    assert Monolith.hello() == :world
  end
end
