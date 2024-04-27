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
    eol =
      if match?(<<_single_delimiter>>, opts[:opening_delimiter]),
        do: Inspect.Algebra.empty(),
        else: Inspect.Algebra.line()

    case Absinthe.Phase.Parse.parse(contents, []) do
      {:ok, document} ->
        document
        |> Inspect.Algebra.to_doc(Inspect.Opts.new([]))
        |> Inspect.Algebra.concat(eol)
        |> Inspect.Algebra.format(opts[:graphql_line_length] || opts[:line_length] || 98)
        |> IO.iodata_to_binary()

      {:error, %Absinthe.Phase.Error{message: message, locations: [location]}} ->
        raise SyntaxError,
          file: opts[:file],
          line: opts[:line] + location.line,
          column: location.column,
          description: message
    end
  end
end
