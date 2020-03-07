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

  @doc """
  create worker process
  """
  def create_worker(count) when not is_integer(count), do: { :error, "not type count" }
  def create_worker(count) when count <= 0, do: { :error, "don't create count" }
  def create_worker(count) do
    res = for _ <- 1..count, do: Exrash.WorkerSup.start_worker()
    { :ok, res }
  end

  @doc """
  call to http request for worker sup
  """
  def call_to_worker(http) do
    Exrash.WorkerSup.call_http_request(http)
  end

  @doc """
  fetch current worker process number
  """
  def fetch_worker_count(), do: Exrash.WorkerSup.fetch_worker_count

  @doc """
  """
  def stop_call_request(), do: { :ok }

  @doc """
  """
  def start_request(config) do
    Exrash.MasterServer.start_request(config)
  end
end
