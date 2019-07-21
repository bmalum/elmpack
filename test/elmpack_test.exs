defmodule ElmpackTest do
  use ExUnit.Case
  doctest Elmpack

  test "greets the world" do
    assert Elmpack.hello() == :world
  end
end
