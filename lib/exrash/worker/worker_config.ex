defmodule Exrash.Worker.WorkerConfig do

  alias __MODULE__
  alias Exrash.Worker.WorkerScenario

  defstruct sleep: 0,
            http: nil,
            count: 0,
            before_scenario_call_func: nil,
            after_scenario_all_func: nil,
            before_call_func: nil,
            after_call_func: nil,
            scenarios: []

  @doc """
  new worker config
  """
  @spec new() :: %WorkerConfig{}
  def new(), do: %WorkerConfig{}

  @spec new(map() | nil) :: %WorkerConfig{} | nil
  def new(config) do
    new_scenarios(config)
    |> (&( put_in(config[:scenarios], &1) )).()
    |> (&( Map.merge(%WorkerConfig{}, &1) )).()
  end

  @doc """
  new worker scenarios
  """
  def new_scenarios(%{ scenarios: scenarios }), do: Enum.map(scenarios, &(WorkerScenario.new(&1)))
  def new_scenarios(_), do: []
end
