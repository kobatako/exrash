defmodule ExrashTest do
  use ExUnit.Case
  doctest Exrash

  test "greets the world" do
    assert Exrash.hello() == :world
  end
end
