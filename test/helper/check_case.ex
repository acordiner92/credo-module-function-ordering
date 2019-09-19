defmodule Test.Helper.CredoModuleFunctionOrdering.CheckCase do
  import ExUnit.Assertions
  alias Credo.Execution
  alias Credo.SourceFile

  def refute_issues(source_file, check, params \\ []) do
    issues = issues_for(source_file, check, create_config(), params)

    assert [] == issues,
           "There should be no issues, got #{Enum.count(issues)}: #{to_inspected(issues)}"

    issues
  end

  def assert_issue(source_file, check \\ nil, params \\ [], callback \\ nil) do
    issues = issues_for(source_file, check, create_config(), params)

    refute Enum.empty?(issues), "There should be one issue, got none."

    assert Enum.count(issues) == 1,
           "There should be only 1 issue, got #{Enum.count(issues)}: #{to_inspected(issues)}"

    if callback do
      issues |> List.first() |> callback.()
    end

    issues
  end

  def to_inspected(value) do
    value
    |> Inspect.Algebra.to_doc(%Inspect.Opts{})
    |> Inspect.Algebra.format(50)
    |> Enum.join("")
  end

  defp issues_for(%SourceFile{} = source_file, check, _exec, params) do
    _issues = check.run(source_file, params)
  end

  defp create_config do
    %Execution{}
    |> Execution.ExecutionSourceFiles.start_server()
    |> Execution.ExecutionIssues.start_server()
    |> Execution.ExecutionTiming.start_server()
  end
end
