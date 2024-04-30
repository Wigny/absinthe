defmodule AbsintheTest do
  use Absinthe.Case, async: true

  import Absinthe, only: [sigil_GQL: 2]

  describe "sigil_GQL" do
    test "parses a simple query" do
      assert "{\n  user(id: 2) {\n    name\n  }\n}\n" = ~GQL"{ user(id: 2) { name } }"
    end

    test "raises a syntax error if it fails to parse a query" do
      assert_raise SyntaxError, ~r/syntax error before: '{'/, fn ->
        ~GQL"{ user(id: 2 { name } }"
      end
    end
  end
end
