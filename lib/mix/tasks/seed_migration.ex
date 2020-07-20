defmodule Mix.Tasks.SeedMigration do
  use Mix.Task

  @shortdoc "Prints SeedMigration help information"

  @moduledoc """
  Prints SeedMigration tasks and their information.
      mix seed_migration
  """

  @doc false
  def run(args) do
    {_opts, args} = OptionParser.parse!(args, strict: [])

    case args do
      [] -> general()
      _ -> Mix.raise("Invalid arguments, expected: mix ecto")
    end
  end

  defp general() do
    Application.ensure_all_started(:seed_migration)
    Mix.shell().info("SeedMigration v#{Application.spec(:seed_migration, :vsn)}")
    Mix.shell().info("A toolkit for seeding data for Elixir.")
    Mix.shell().info("\nAvailable tasks:\n")
    Mix.Tasks.Help.run(["--search", "seed_migration."])
    Mix.Tasks.Help.run(["--search", "seed."])
  end
end
