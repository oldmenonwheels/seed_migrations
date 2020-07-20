defmodule Mix.SeedMigration do
  @moduledoc false

  @doc """
  Parses the repository option from the given command line args list.
  If no repo option is given, it is retrieved from the application environment.
  """
  @spec parse_repo([term]) :: [Ecto.Repo.t()]
  def parse_repo(args) do
    parse_repo(args, [])
  end

  defp parse_repo([key, value | t], acc) when key in ~w(--repo -r) do
    parse_repo(t, [Module.concat([value]) | acc])
  end

  defp parse_repo([_ | t], acc) do
    parse_repo(t, acc)
  end

  defp parse_repo([], []) do
    apps =
      if apps_paths = Mix.Project.apps_paths() do
        apps_paths |> Map.keys() |> Enum.sort()
      else
        [Mix.Project.config()[:app]]
      end

    apps
    |> Enum.flat_map(fn app ->
      Application.load(app)
      Application.get_env(app, :ecto_repos, [])
    end)
    |> Enum.uniq()
    |> case do
      [] ->
        Mix.shell().error("""
        warning: could not find Ecto repos in any of the apps: #{inspect(apps)}.
        You can avoid this warning by passing the -r flag or by setting the
        repositories managed by those applications in your config/config.exs:
            config #{inspect(hd(apps))}, ecto_repos: [...]
        """)

        []

      repos ->
        repos
    end
  end

  defp parse_repo([], acc) do
    Enum.reverse(acc)
  end

  @doc """
  Ensures the given module is an Ecto.Repo.
  """
  @spec ensure_repo(module, list) :: Ecto.Repo.t()
  def ensure_repo(repo, args) do
    Mix.Task.run("loadpaths", args)

    unless "--no-compile" in args do
      Mix.Task.run("compile", args)
    end

    case Code.ensure_compiled(repo) do
      {:module, _} ->
        if function_exported?(repo, :__adapter__, 0) do
          repo
        else
          Mix.raise(
            "Module #{inspect(repo)} is not an Ecto.Repo. " <>
              "Please configure your app accordingly or pass a repo with the -r option."
          )
        end

      {:error, error} ->
        Mix.raise(
          "Could not load #{inspect(repo)}, error: #{inspect(error)}. " <>
            "Please configure your app accordingly or pass a repo with the -r option."
        )
    end
  end

  @doc """
  Asks if the user wants to open a file based on ECTO_EDITOR.
  """
  @spec open?(binary) :: boolean
  def open?(file) do
    editor = System.get_env("ECTO_EDITOR") || ""

    if editor != "" do
      :os.cmd(to_charlist(editor <> " " <> inspect(file)))
      true
    else
      false
    end
  end

  @doc """
  Ensures the given repository's migrations paths exists on the file system.
  """
  @spec ensure_migrations_paths(Ecto.Repo.t(), Keyword.t()) :: String.t()
  def ensure_migrations_paths(repo, opts) do
    paths = Keyword.get_values(opts, :migrations_path)
    paths = if paths == [], do: [Path.join(source_repo_priv(repo), "migrations")], else: paths

    if not Mix.Project.umbrella?() do
      for path <- paths, not File.dir?(path) do
        raise_missing_migrations(Path.relative_to_cwd(path), repo)
      end
    end

    paths
  end

  defp raise_missing_migrations(path, repo) do
    Mix.raise("""
    Could not find migrations directory #{inspect(path)}
    for repo #{inspect(repo)}.
    This may be because you are in a new project and the
    migration directory has not been created yet. Creating an
    empty directory at the path above will fix this error.
    If you expected existing migrations to be found, please
    make sure your repository has been properly configured
    and the configured path exists.
    """)
  end

  @doc """
  Returns the private repository path relative to the source.
  """
  def source_repo_priv(repo) do
    config = repo.config()
    priv = config[:priv] || "priv/#{repo |> Module.split() |> List.last() |> Macro.underscore()}"
    app = Keyword.fetch!(config, :otp_app)
    Path.join(Mix.Project.deps_paths()[app] || File.cwd!(), priv)
  end
end
