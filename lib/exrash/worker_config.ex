defmodule Exrash.WorkerConfig do

  defstruct sleep: 0, http: nil, count: 0, scenario: %{
    http: nil,
    def_header: nil
  }

end
