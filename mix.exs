defmodule Gpp.MixProject do
  use Mix.Project

  @name "Gpp"
  @version "0.1.0"
  @repo_url "https://github.com/Adaptmx/gpp"

  def project do
    [
      app: :gpp,
      version: @version,
      elixir: "~> 1.14",
      description: "Decode IAB GPP strings including the region specific sections they contain.",
      package: package(),
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      name: @name,
      source_url: @repo_url,
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
      {:benchee, "~> 1.0", only: :dev},
      {:eflambe, "~> 0.3.0", only: :dev}
    ]
  end

  defp package do
    %{
      licenses: ["Apache 2"],
      maintainers: ["Nico Piderman"],
      links: %{"GitHub" => @repo_url}
    }
  end

  defp docs do
    [
      main: "Gpp",
      source_ref: "v#{@version}",
      source_url: @repo_url
    ]
  end
end
