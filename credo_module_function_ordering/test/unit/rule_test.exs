defmodule Test.Unit.CredoModuleFunctionOrdering.Rule do
  use CredoModuleFunctionOrdering.TestHelper

  @described_check CredoModuleFunctionOrdering.Rule

  setup_all do
    import Supervisor.Spec, warn: false

    children = [
      worker(Credo.CLI.Output.Shell, []),
      worker(Credo.Service.SourceFileScopes, []),
      worker(Credo.Service.SourceFileAST, []),
      worker(Credo.Service.SourceFileLines, []),
      worker(Credo.Service.SourceFileSource, [])
    ]

    opts = [strategy: :one_for_one, name: Credo.Supervisor]
    {:ok, _} = Supervisor.start_link(children, opts)
    :ok
  end

  function_definitions = [
    defstruct: "defstruct name: nil, age: nil",
    defexception: "defexception [:message]",
    defguard: "defguard is_even(value) when is_integer(value) and rem(value, 2) == 0",
    def: "def sum(a, b), do: a + b",
    defdelegate: "defdelegate reverse(list), to: Enum",
    defmacro: "
       defmacro unless(expr, opts) do
         quote do
           if !unquote(expr), unquote(opts)
         end
       end",
    defguardp: "defguardp is_even_private(value) when is_integer(value) and rem(value, 2) == 0",
    defp: "defp sum_private(a, b), do: a + b",
    defmacrop: "
       defmacrop unless_private(expr, opts) do
         quote do
           if !unquote(expr), unquote(opts)
         end
       end
     ",
    defoverridable: "defoverridable 8"
  ]

  Enum.each(function_definitions, fn {type, value} ->
    function_definitions
    |> Enum.slice(
      Enum.find_index(function_definitions, fn {x, _} -> x == type end) + 1,
      Enum.count(function_definitions)
    )
    |> Enum.each(fn {other_type, other_value} ->
      test "if #{type} is above #{other_type} then no issues are created" do
        value = unquote(value)
        other_value = unquote(other_value)

        """
        defmodule Test do

          #{value}

          #{other_value}

        end
        """
        |> to_source_file
        |> refute_issues(@described_check)
      end
    end)
  end)

  Enum.each(function_definitions, fn {type, value} ->
    function_definitions
    |> Enum.slice(
      Enum.find_index(function_definitions, fn {x, _} -> x == type end) + 1,
      Enum.count(function_definitions)
    )
    |> Enum.each(fn {other_type, other_value} ->
      test "if #{type} is below #{other_type} then issues are created" do
        value = unquote(value)
        other_value = unquote(other_value)

        """
        defmodule Test do

          #{other_value}

          #{value}

        end
        """
        |> to_source_file
        |> assert_issue(@described_check)
      end
    end)
  end)
end
