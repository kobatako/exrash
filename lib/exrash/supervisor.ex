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
        id: Exrash.Exporter.IOExporter,
        start: {Exrash.Exporter.IOExporter, :start_link, []},
        restart: :temporary,
        shutdown: :brutal_kill,
        type: :worker
      },
      %{
        id: Exrash.Report,
        start: {Exrash.Report, :start_link, [Exrash.Exporter.IOExporter]},
        restart: :temporary,
        shutdown: :brutal_kill,
        type: :worker
      }
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
