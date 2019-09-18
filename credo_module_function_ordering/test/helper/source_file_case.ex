defmodule Test.Helper.CredoModuleFunctionOrdering.SourceFileCase do
  alias Test.Helper.CredoModuleFunctionOrdering.FilenameGenerator

  def to_source_file(source) do
    to_source_file(source, FilenameGenerator.next())
  end

  def to_source_file(source, filename) do
    case Credo.SourceFile.parse(source, filename) do
      %{status: :valid} = source_file ->
        source_file

      _ ->
        raise "Source could not be parsed!"
    end
  end
end
