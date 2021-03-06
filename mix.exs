defmodule FactoryMacro.Mixfile do
  use Mix.Project

  def project do
    [app: :factory_macro,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :faker]]
  end

  defp deps do
    [
      {:faker, github: "igas/faker"},
      {:ecto, "~> 1.0.2"}
    ]
  end
end
