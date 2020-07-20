defmodule Mix.Tasks.Seed.Gen.Migration do
  use Mix.Task

  import Macro, only: [camelize: 1, underscore: 1]
  import Mix.Generator
  import Mix.SeedMigration

  @shortdoc "Generates a new seed migration"

  @switches [
    no_compile: :boolean,
    no_deps_check: :boolean,
    path: :string
  ]

  @aliases []

  @moduledoc """
  Generates a seed migration.
  ## Examples
      mix ecto.gen.migration seed_data_to_posts_table
  The generated migration filename will be prefixed with the current
  timestamp in UTC which is used for versioning and ordering.
  By default, the migration will be generated to the
  "priv/YOUR_REPO/seeds" directory of the current application
  but it can be configured to be any subdirectory of `priv` by
  specifying the `:priv` key under the repository configuration.
  ## Command line options
    * `--no-compile` - does not compile applications before running
    * `--no-deps-check` - does not check depedendencies before running
    * `--path` - the path to create migration, defaults to `priv/repo/migrations`
  """

  @impl true
  def run(args) do
    case OptionParser.parse!(args, strict: @switches, aliases: @aliases) do
      {opts, [name]} ->
        path = opts[:path] || "priv/repo/seeds/"

        base_name = "#{underscore(name)}.exs"
        file = Path.join(path, "#{timestamp()}_#{base_name}")
        unless File.dir?(path), do: create_directory(path)

        fuzzy_path = Path.join(path, "*_#{base_name}")

        if Path.wildcard(fuzzy_path) != [] do
          Mix.raise(
            "migration can't be created, there is already a migration file with name #{name}."
          )
        end

        assigns = [mod: Module.concat([camelize(name)])]
        create_file(file, migration_template(assigns))

        file

      {_, _} ->
        Mix.raise(
          "expected seed.gen.migration to receive the migration file name, " <>
            "got: #{inspect(Enum.join(args, " "))}"
        )
    end
  end

  defp timestamp do
    {{y, m, d}, {hh, mm, ss}} = :calendar.universal_time()
    "#{y}#{pad(m)}#{pad(d)}#{pad(hh)}#{pad(mm)}#{pad(ss)}"
  end

  defp pad(i) when i < 10, do: <<?0, ?0 + i>>
  defp pad(i), do: to_string(i)

  embed_template(:migration, """
  defmodule <%= inspect @mod %> do
    use Seed.Migration

    def up do

    end

    def down do

    end
  end
  """)
end
