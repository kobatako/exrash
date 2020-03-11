defmodule Exrash.Worker.WorkerConfig do

  alias Exrash.Worker.WorkerScenario

  defstruct sleep: 0, http: nil, count: 0, base_fqdn: nil, scenarios: []

end
