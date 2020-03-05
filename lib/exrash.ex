defmodule Exrash do
  @moduledoc """
  Documentation for `Exrash`.
  """

  use Supervisor

  @doc """
  start exrash process
  """
  def start() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  """
  def init([]) do
    children = [
      %{
        id: Exrash.Supervisor,
        start: {Exrash.Supervisor, :start_link, []},
        type: :supervisor
      }
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
