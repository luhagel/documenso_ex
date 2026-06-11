defmodule DocumensoTest do
  use ExUnit.Case
  doctest Documenso

  describe "new/0,1" do
    test "delegates to Documenso.Api.new with no options" do
      assert Documenso.new().options == Documenso.Api.new().options
    end

    test "delegates to Documenso.Api.new with options" do
      opts = [receive_timeout: 1234]
      assert Documenso.new(opts).options == Documenso.Api.new(opts).options
    end
  end
end
