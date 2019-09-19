defmodule CredoModuleFunctionOrdering.Rule do
  @moduledoc """
  In a module, functions should be ordered to provide better readability
  across the code base by exposing the most important functions definition types
  first (e.g public ones) followed by the private functions
  The order of function heirarchy in a module from top to bottom is as follows:

  defstruct
  defexception
  defguard
  def
  defdelegate
  defmacro
  defguardp
  defp
  defmacrop
  defoverridable
  """

  @explanation [
    check: @moduledoc
  ]

  use Credo.Check, category: :readability

  @function_weighings %{
    defstruct: 0,
    defexception: 1,
    defguard: 2,
    def: 3,
    defdelegate: 4,
    defmacro: 5,
    defguardp: 6,
    defp: 7,
    defmacrop: 8,
    defoverridable: 9
  }

  @spec run(Credo.SourceFile.t(), Keyword.t()) :: List.t()
  def run(source_file, params \\ []) do
    issue_meta = IssueMeta.for(source_file, params)

    Credo.Code.prewalk(
      source_file,
      &traverse(&1, &2, issue_meta)
    )
  end

  defp get_weighed_function_definitions(ast),
    do:
      get_all_function_definitions(ast)
      |> Enum.sort(fn a, b ->
        Map.get(@function_weighings, a.function_type) <=
          Map.get(@function_weighings, b.function_type)
      end)

  defp traverse(
         {:defmodule, _meta, _arguments} = ast,
         issues,
         issue_meta
       ) do
    get_all_function_definitions(ast)
    |> List.myers_difference(get_weighed_function_definitions(ast))
    |> Keyword.get(:ins, [])
    |> case do
      [] ->
        {ast, issues}

      found_issues ->
        formatted_issues =
          Enum.map(found_issues, fn x -> issue_for(issue_meta, x.line_number) end)

        {ast, [formatted_issues | issues]}
    end
  end

  defp traverse(ast, issues, _issue_meta) do
    {ast, issues}
  end

  defp traverse_for_function_definitions({function_type, metadata, _} = node, acc) do
    @function_weighings
    |> Map.has_key?(function_type)
    |> case do
      true ->
        {node,
         acc ++ [%{function_type: function_type, line_number: Keyword.get(metadata, :line)}]}

      false ->
        {node, acc}
    end
  end

  defp traverse_for_function_definitions(node, acc), do: {node, acc}

  defp get_all_function_definitions(ast) do
    pre_traversal = fn node, acc ->
      {node, acc}
    end

    {_, acc} =
      ast |> Macro.traverse([], pre_traversal, &traverse_for_function_definitions(&1, &2))

    acc
  end

  defp issue_for(issue_meta, line_no) do
    format_issue(
      issue_meta,
      message: """
        Functions should be ordered in a module as follows:
        defstruct > defexception > defguard > def > defdelegate >
        defmacro > defguardp > defp > defmacrop > defoverridable
      """,
      line_no: line_no
    )
  end
end
