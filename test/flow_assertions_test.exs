defmodule FlowAssertionsTest do
  use ExUnit.Case
  doctest FlowAssertions

  test "greets the world" do
    assert FlowAssertions.hello() == :world
  end
end
