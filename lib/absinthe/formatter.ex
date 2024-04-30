defmodule Absinthe.Formatter do
  @moduledoc """
  Formatter task for graphql

  Will format files with the extensions .graphql or .gql

  ## Example
  ```elixir
  Absinthe.Formatter.format("{ version }")
  "{\n  version\n}\n"
  ```


  From Elixir 1.13 onwards the Absinthe.Formatter can be added to
  the formatter as a plugin:

  ```elixir
  # .formatter.exs
  [
    # Define the desired plugins
    plugins: [Absinthe.Formatter],
    # Remember to update the inputs list to include the new extensions
    inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}", "{lib,priv}/**/*.{gql,graphql}"]
  ]
  ```
  """

  @behaviour Mix.Tasks.Format

  @impl true
  def features(_opts) do
    [sigils: [:GQL], extensions: [".graphql", ".gql"]]
  end

  @impl true
  def format(contents, opts) do
    case Absinthe.Phase.Parse.parse(contents, []) do
      {:ok, document} ->
        inspect(document)

      {:error, %Absinthe.Phase.Error{message: message, locations: [location]}} ->
        raise SyntaxError,
          file: opts[:file],
          line: opts[:line] + location.line,
          column: location.column,
          description: message
    end
  end
end
