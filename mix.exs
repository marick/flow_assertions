defmodule FlowAssertions.MixProject do
  use Mix.Project

  @github "https://github.com/marick/flow_assertions"
  @version "0.7.1"

  def project do
    [

      description: """
      Assertions tailored for use in pipelines. Common assertions
      extracted for easy reuse. Tabular tests.
      """,
      
      app: :flow_assertions,
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Flow Assertions",
      source_url: @github,
      docs: [
        main: "FlowAssertions",
        extras: ["CHANGELOG.md"],
        nest_modules_by_prefix: [FlowAssertions.Define],
        groups_for_modules: [
          "Common Assertions": [
            FlowAssertions.EnumA,
            FlowAssertions.MapA,
            FlowAssertions.MiscA,
            FlowAssertions.StructA,
          ],
          "Other Assertions": [
            FlowAssertions.AssertionA,
            FlowAssertions.NoValueA,
          ],
          "Helpers": [
            FlowAssertions.Checkers,
            FlowAssertions.TabularA,
          ],
          "Defining Assertions": [
            FlowAssertions.Define,
            FlowAssertions.Define.BodyParts,
            FlowAssertions.Define.Defchain,
            FlowAssertions.Define.Defchecker,
            FlowAssertions.Define.Tabular,
          ]
        ]
      ],

      package: [
        contributors: ["marick@exampler.com"],
        maintainers: ["marick@exampler.com"],
        licenses: ["Unlicense"],
        links: %{
          "GitHub" => @github
        },
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
