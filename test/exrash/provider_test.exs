defmodule Exrash.ProviderTest do

  use  ExUnit.Case

  alias Exrash.Provider
  alias Exrash.Master.MasterConfig
  alias Exrash.Worker.WorkerConfig

  test "provider config" do
    assert %Provider{} == Provider.new(%{})

    assert %Provider{master_config: %MasterConfig{}} == Provider.new(%{master_config: %{}})
    assert %Provider{master_config: %MasterConfig{http: "http://localhost", max_proc: 10}}
      == Provider.new(%{master_config: %{http: "http://localhost", max_proc: 10}})

    assert %Provider{worker_config: %WorkerConfig{}} == Provider.new(%{worker_config: %{}})
    assert %Provider{worker_config: %WorkerConfig{sleep: 5, count: 10}}
      == Provider.new(%{worker_config: %{sleep: 5, count: 10}})

    assert %Provider{worker_config: %WorkerConfig{sleep: 5, count: 10}, master_config: %MasterConfig{max_proc: 10}}
      == Provider.new(%{worker_config: %{sleep: 5, count: 10}, master_config: %{max_proc: 10}})
  end
end
