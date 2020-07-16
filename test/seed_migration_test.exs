defmodule SeedMigrationTest do
  use ExUnit.Case
  doctest SeedMigration

  test "greets the world" do
    assert SeedMigration.hello() == :world
  end
end
