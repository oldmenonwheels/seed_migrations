defmodule Mix.Tasks.Seed.Gen.MigrationTest do
  use ExUnit.Case, async: true

  import Support.FileHelpers
  import Mix.Tasks.Seed.Gen.Migration, only: [run: 1]

  @seed_path Path.join(tmp_path(), "seeds")

  setup do
    File.rm_rf!(unquote(tmp_path()))

    on_exit(fn ->
      File.rm_rf!(unquote(tmp_path))
    end)
  end

  test "generates a new migration" do
    path = run(["my_migration", "--path", @seed_path])

    assert Path.dirname(path) == @seed_path
    assert Path.basename(path) =~ ~r/^\d{14}_my_migration\.exs$/

    assert_file(path, fn file ->
      assert file =~ "defmodule MyMigration do"
      assert file =~ "use Seed.Migration"
      assert file =~ "def up do"
      assert file =~ "def down do"
    end)
  end

  test "raises error with same name" do
    # first run
    run(["my_migration", "--path", @seed_path])

    # second run raises error
    assert_raise Mix.Error, ~r/^migration can't be created/, fn ->
      run(["my_migration", "--path", @seed_path])
    end
  end
end
