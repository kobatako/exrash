defmodule Exrash.Examples do

  alias __MODULE__

  alias Exrash.Master.MasterConfig
  alias Exrash.Worker.WorkerConfig
  alias Exrash.Worker.WorkerScenario

  def sample_call() do
    Exrash.start
    Exrash.Provider.set_provider_config(
      %Exrash.Provider{
        master_config: %MasterConfig{
          http: "http://192.168.33.142",
          init_proc: 5, interval_time: 2, interval_count: 5, add_proc: 0
        }
      }
    )
    Exrash.Provider.start_http_request
  end

  def sample_worker_process() do
    Exrash.start
    Exrash.Provider.set_provider_config(
      %Exrash.Provider{
        worker_config: %WorkerConfig{
          http: "http://192.168.33.142",
          count: 5, sleep: 0,
          scenarios: [
            %WorkerScenario{
              url: "http://192.168.33.142/index.html",
              method: :get
            },
            %WorkerScenario{
              url: "http://192.168.33.142/hello.html",
              method: :get
            },
            %WorkerScenario{
              url: URI.parse("http://192.168.33.142/sample.html"),
              method: :get
            }
          ]
        },
        master_config: %MasterConfig{
          http: "http://192.168.33.142",
          init_proc: 5, interval_time: 2, interval_count: 5, add_proc: 0
        }
      }
    )
    Exrash.Provider.start_worker_process()
  end

  def before_call_func({ method, url, header }) do
    IO.inspect "before call func"
    {method, url, header}
  end

  def after_call_func({ res, from, to }) do
    IO.inspect "after call func"
    {res, from, to}
  end
end
