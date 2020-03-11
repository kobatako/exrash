defmodule Exrash.Worker.WorkerConfig do

  alias Exrash.Worker.WorkerScenario

  defstruct sleep: 0,
            http: nil,
            count: 0,
            before_scenario_call_func: nil,
            after_scenario_all_func: nil,
            before_call_func: nil,
            after_call_func: nil,
            scenarios: []

end
