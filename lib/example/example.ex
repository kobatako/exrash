defmodule Exrash.Example do

  def sample_call() do
    Exrash.start
    Exrash.Provider.set_provider_config(
      %Exrash.Provider{
        http: "http://192.168.33.142",
        init_proc: 5, interval_time: 2, interval_count: 5, add_proc: 0}
    )
    Exrash.Provider.start_http_request
  end

  def sample_worker_process() do
    Exrash.start
    Exrash.Provider.set_provider_config(
      %Exrash.Provider{
        http: "http://192.168.33.142",
        count: 5, sleep: 0,
        init_proc: 5, interval_time: 1, interval_count: 2, add_proc: 5}
    )
    Exrash.Provider.start_worker_process()
  end
end
