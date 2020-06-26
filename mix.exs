defmodule VKAPI.MixProject do
  use Mix.Project

  def project do
    [
      app: :vkapi,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      mod: {VKAPI.SessionProvider, []}
    ]
  end

  defp deps do
    [
      {:jason, "~> 1.2"},
    ]
  end
end
