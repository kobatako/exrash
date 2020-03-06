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
      }
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  create worker process
  """
  def create_worker(count) do
    for _ <- 1..count, do: Exrash.WorkerSup.start_worker()
  end

  @doc """
  call to http request for worker sup
  """
  def call_to_worker(http) do
    Exrash.WorkerSup.call_http_request(http)
  end
end
