defmodule Genealogist.Mixfile do
  use Mix.Project

  def project do
    [
      app: :genealogist,
      version: "0.1.0",
      elixir: "~> 1.4",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),
      name: "Genealogist",
      description: "Tool to generate current supervision tree including names from process registries"
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      {:dotex, ">= 0.0.0"},
      {:credo, "~> 0.8", only: [:dev, :test]},
    ]
  end

  defp package do
    %{
      maintainers: ["Alan Harper"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/aussiegeek/genealogist"}
    }
  end
end
