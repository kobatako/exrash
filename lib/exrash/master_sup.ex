defmodule Exrash.MasterSup do

  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    children = [
      %{
        id: Exrash.WorkerSup,
        start: {Exrash.WorkerSup, :start_link, []},
        restart: :temporary,
        shutdown: :brutal_kill,
        type: :supervisor
      },
      %{
        id: Exrash.MasterServer,
        start: {Exrash.MasterServer, :start_link, []},
        restart: :temporary,
        shutdown: :brutal_kill,
        type: :worker
      }
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  def start_http_request(config) do
    Exrash.MasterServer.start_http_request(config)
  end

  def start_worker_process(master_config, worker_config) do
    Exrash.MasterServer.start_worker_process(master_config, worker_config)
  end
end
