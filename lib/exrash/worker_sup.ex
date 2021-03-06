defmodule Exrash.WorkerSup do
  @moduledoc """
  worker supervisor
  """

  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    {:ok, { {:one_for_one, 6, 60}, []} }
  end

  @doc """
  creat worker process
  """
  def create_worker(), do: Supervisor.start_child(__MODULE__, child_worker(make_ref()))


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
  def call_worker_http_request({_, pid, :worker, _}, http), do: Exrash.Worker.async_request_http(pid, %{"http" => http})

  @doc """
  fetch for worker count
  """
  def fetch_worker_count() do
    Supervisor.count_children(__MODULE__)
    |> (fn %{workers: count} -> count end).()
  end

  @doc """
  fetch working process
  """
  def fetch_workers(), do: Supervisor.which_children(__MODULE__)

  @doc """
  call to running
  """
  def running_worker({:ok, pid}), do: Exrash.Worker.running_worker(pid)
  def running_worker({_, id, :worker, _}), do: Exrash.Worker.running_worker(id)

  @doc """
  set worker config
  """
  def set_worker_config(config) do
    Supervisor.which_children(__MODULE__)
    |> Enum.map(fn worker -> set_worker_config(worker, config) end)
  end

  @doc """
  set worker config
  """
  def set_worker_config({_, pid, :worker, _}, config),do: Exrash.Worker.set_config(pid, config)
  def set_worker_config({:ok, pid}, config), do: Exrash.Worker.set_config(pid, config)

  @doc """
  start worker process
  set worker config and start worker process
  """
  def start_worker(worker, config) do
    set_worker_config(worker, config)
    running_worker(worker)
  end

  @doc """
  stop worker process
  """
  def stop_worker({_ref, id, :worker, _}, reason), do: GenServer.stop(id, reason)
end
