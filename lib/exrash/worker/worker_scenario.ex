defmodule Exrash.Worker.WorkerScenario do

  alias __MODULE__

  defstruct url: "",
            method: :get,
            body: nil,
            headers: [],
            before_call_func: nil,
            after_call_func: nil

  @doc """
  """
  @spec
  @spec new() :: %WorkerScenario{}
  def new(), do: %WorkerScenario{}

  @spec new(map()) :: %WorkerScenario{}
  def new(config), do: Map.merge(%WorkerScenario{}, config)
end
