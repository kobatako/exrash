defmodule Exrash.Worker.WorkerScenario do

  defstruct url: "",
            method: :get,
            body: nil,
            header: [],
            before_call_func: nil,
            after_call_func: nil

end
