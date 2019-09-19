ExUnit.start()

Test.Helper.CredoModuleFunctionOrdering.Application.start([], [])

defmodule CredoModuleFunctionOrdering.TestHelper do
  defmacro __using__(_) do
    quote do
      use ExUnit.Case, async: true
      import Test.Helper.CredoModuleFunctionOrdering.SourceFileCase
      import Test.Helper.CredoModuleFunctionOrdering.CheckCase
    end
  end
end
