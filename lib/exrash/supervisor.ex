defmodule Exrash.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    {:ok, { {:one_for_one, 6, 60}, []} }
  end

  def start_worker() do
    child_spec = child_worker(make_ref())
    Supervisor.start_child(__MODULE__, child_spec)
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
end
