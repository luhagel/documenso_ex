defmodule DocumensoTest do
  use ExUnit.Case
  doctest Documenso

  test "greets the world" do
    assert Documenso.hello() == :world
  end
end
