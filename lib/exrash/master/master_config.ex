defmodule Exrash.Master.MasterConfig do

  alias __MODULE__

  defstruct http: "",
            init_proc: 0,
            add_proc: 0,
            max_proc: nil,
            interval_count: 0,
            interval_time: nil

  @doc """
  """
  @spec new() :: %MasterConfig{}
  def new(), do: %MasterConfig{}

  @spec new(map() | nil) :: %MasterConfig{} | nil
  def new(config), do: Map.merge(%MasterConfig{}, config)
end
