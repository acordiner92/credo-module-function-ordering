defmodule Test.Helper.CredoModuleFunctionOrdering.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Test.Helper.CredoModuleFunctionOrdering.FilenameGenerator, [])
    ]

    opts = [
      strategy: :one_for_one,
      name: Test.Helper.CredoModuleFunctionOrdering.Application.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end
end
