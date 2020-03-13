defmodule Exrash.Worker.WorkerConfigTest do

  use ExUnit.Case

  alias Exrash.Worker.WorkerConfig
  alias Exrash.Worker.WorkerScenario

  test "create worker config" do
    assert %WorkerConfig{} == WorkerConfig.new(%{})
    assert %WorkerConfig{sleep: 5} == WorkerConfig.new(%{sleep: 5})
    assert %WorkerConfig{sleep: 10, http: "http://localhost", count: 5}
              == WorkerConfig.new(%{sleep: 10, http: "http://localhost", count: 5})

    assert %WorkerConfig{scenarios: []} == WorkerConfig.new(%{})
    assert %WorkerConfig{scenarios: [%WorkerScenario{}]} == WorkerConfig.new(%{scenarios: [%{}]})
    assert %WorkerConfig{scenarios: [
      %WorkerScenario{url: "http://localhost", body: "request body"}, %WorkerScenario{method: :post}
    ]}
    == WorkerConfig.new(%{scenarios: [%{url: "http://localhost", body: "request body"}, %{method: :post}]})
  end
end
