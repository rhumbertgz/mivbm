defmodule Mivbm.MixProject do
  use Mix.Project

  def project do
    [
      app: :mivbm,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:mivbc, git: "git@github.com:rhumbertgz/mivbc.git",  tag: "0.1.2"},
    ]
  end
end
