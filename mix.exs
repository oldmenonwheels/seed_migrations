defmodule SeedMigration.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :seed_migration,
      version: @version,
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      ecto_dep(),
      {:telemetry, "~> 0.4.0"},

      # Drivers
      {:db_connection, "~> 2.2"},
      postgrex_dep(),
      myxql_dep(),
      tds_dep()
    ]
  end

  defp ecto_dep do
    if path = System.get_env("ECTO_PATH") do
      {:ecto, path: path}
    else
      {:ecto, "~> 3.4.3"}
    end
  end

  defp postgrex_dep do
    if path = System.get_env("POSTGREX_PATH") do
      {:postgrex, path: path}
    else
      {:postgrex, "~> 0.15.0", optional: true}
    end
  end

  defp myxql_dep do
    if path = System.get_env("MYXQL_PATH") do
      {:myxql, path: path}
    else
      {:myxql, "~> 0.3.0 or ~> 0.4.0", optional: true}
    end
  end

  defp tds_dep do
    if path = System.get_env("TDS_PATH") do
      {:tds, path: path}
    else
      {:tds, "~> 2.1.0", optional: true}
    end
  end
end
