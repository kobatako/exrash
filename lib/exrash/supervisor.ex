defmodule Exrash.Supervisor do
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    Supervisor.init(child_spec, strategy: :one_for_one)
  end

  defp child_spec() do
    [
      child_worker
    ]
  end

  @doc """
  child spec worker process
  """
  defp child_worker() do
    %{
      id: Exrash.Worker,
      start: {Exrash.Worker, :start_link, [[:hello]]},
      type: :worker
    }
  end
end
