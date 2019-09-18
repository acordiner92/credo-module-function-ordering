defmodule CredoModuleFunctionOrdering.MixProject do
  use Mix.Project

  def project do
    [
      app: :credo_module_function_ordering,
      version: "0.1.0",
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      description: "Credo rule for ordering of different functions types within a module",
      package: [
        maintainers: ["acac99"],
        licenses: ["MIT"],
        maintainers: ["acacwork99@gmail.com"],
        links: %{"Github" => "https://github.com/acac99/credo-module-function-ordering"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    []
  end

  defp elixirc_paths(:test), do: ["lib", "test/helper"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21.2", only: :dev, runtime: false}
    ]
  end
end
