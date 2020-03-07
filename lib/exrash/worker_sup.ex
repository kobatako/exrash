defmodule Exrash.WorkerSup do

  use Supervisor
  alias Exrash.HttpClient

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    HttpClient.start
    {:ok, { {:one_for_one, 6, 60}, []} }
  end

  @doc """
  """
  def start_worker() do
    Supervisor.start_child(__MODULE__, child_worker(make_ref()))
  end

  @doc """
  child spec worker process
  """
  defp child_worker(pid) do
    %{
      id: pid,
      start: {Exrash.Worker, :start_link, [pid]},
      restart: :temporary,
      shutdown: :brutal_kill,
      type: :worker
    }
  end

  @doc """
  call to http request
  """
  def call_http_request(http) do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn worker -> call_worker_http_request(worker, http) end)
  end

  @doc """
  call http request for worker process
  """
  def call_worker_http_request({_, pid, :worker, _}, http) do
    Exrash.Worker.async_request_http(pid, %{"http" => http})
  end

  @doc """
  fetch for worker count
  """
  def fetch_worker_count() do
    Supervisor.count_children(__MODULE__)
    |> (fn %{workers: count} -> count end).()
  end
end
