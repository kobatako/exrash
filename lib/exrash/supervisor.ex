defmodule Exrash.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    children = [
      %{
        id: Exrash.MasterSup,
        start: {Exrash.MasterSup, :start_link, []},
        restart: :temporary,
        shutdown: :brutal_kill,
        type: :supervisor
      },
      %{
        id: Exrash.Provider,
        start: {Exrash.Provider, :start_link, []},
        restart: :temporary,
        shutdown: :brutal_kill,
        type: :worker
      },
      %{
        id: Exrash.ResultReport,
        start: {Exrash.ResultReport, :start_link, []},
        restart: :temporary,
        shutdown: :brutal_kill,
        type: :worker
      }
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
