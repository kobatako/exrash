defmodule Exrash.Examples do

  alias __MODULE__
  alias Exrash.Request.HttpRequest

  def sample_call() do
    Exrash.start
    Exrash.Interface.set_configure(
      %{
        master_config: %{
          http: "http://192.168.33.142",
          init_proc: 5, interval_time: 2, interval_count: 5, add_proc: 0
        }
      }
    )
    Exrash.Provider.start_http_request
  end

  def sample_worker_process() do
    Exrash.start
    Exrash.Interface.set_configure(
      %{
        worker_config: %{
          http: "http://192.168.33.142",
          count: 5, sleep: 0,
          scenarios: [
            %{
              url: "http://192.168.33.142/index.html",
              method: :get,
              call_request: (&(call_request(&1)))
            },
            %{
              url: "http://192.168.33.142/hello.html",
              method: :get,
              call_request: (&(call_request(&1)))
            },
            %{
              url: URI.parse("http://192.168.33.142/sample.html"),
              method: :get,
              call_request: (&(call_request(&1)))
            }
          ]
        },
        master_config: %{
          http: "http://192.168.33.142",
          init_proc: 5, interval_time: 2, interval_count: 5, add_proc: 0
        }
      }
    )
    Exrash.Interface.start()
  end

  def call_request(args) do
    HttpRequest.call_request(args)
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
