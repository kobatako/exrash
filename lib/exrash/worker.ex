defmodule Exrash.Worker do

  use GenServer
  alias Exrash.Report
  alias Exrash.Client.HttpClient
  alias Exrash.Worker.WorkerConfig
  alias Exrash.Worker.WorkerScenario

  def start_link(pid) do
    GenServer.start_link(__MODULE__, [], name: {:global, pid})
  end

  def init(__init__) do
    {:ok, %{config: nil}}
  end

  @doc """
  set config
  """
  def handle_call({:set_config, config}, _from, state) do
    {:reply, { :ok, :set_config }, %{ state | config: config }}
  end

  @doc """
  """
  def handle_call({:request_http, %{"http" => http}}, _from, state) do
    res = HttpClient.get! http
    {:reply, res, state}
  end

  @doc """
  call http request
  """
  def handle_cast({:request_http, %{"http" => http}}, state) do
    { res, from, to } = Exrash.Request.HttpRequest.call_request(:get, http, [])
    Exrash.Report.add_report(res, from, to)
    {:noreply, state}
  end

  @doc """
  running worker process
  worker process work to http request
  """
  def handle_cast({ :running }, %{ config: nil }=state), do: {:noreply, state}
  def handle_cast({ :running }, %{ config: %{ count: 0 } }=state), do: {:noreply, state}
  def handle_cast({ :running }, %{ config: config }=state) do
    running_scenario(config.scenarios, config.before_call_func, config.after_call_func)

    Process.sleep(config.sleep * 1000)
    Exrash.Worker.running_worker(self)
    { :noreply, %{ state| config: %{ config| count: config.count - 1 }}}
  end

  @doc """
  terminate worker
  """
  def terminate(reson, state) do
    { :shutdown, "terminate worker process" }
  end

  @doc """
  running for scenarios request
  """
  @spec running_scenario(list(%WorkerScenario{}), fun(), fun()) :: { :ok }
  def running_scenario([], _, _), do: { :ok }
  def running_scenario([scenario| tail], before_func, after_func) do
    { scenario.method, scenario.url, scenario.headers }
    |> (&( call_before_func(before_func, &1) )).() # call back before function
    |> (&( call_before_func(scenario.before_call_func, &1) )).() # call back scenario before function
    |> call_request(scenario)
    |> (&( call_after_func(scenario.after_call_func, &1) )).() # call back scenario after function
    |> (&( call_after_func(after_func, &1) )).() # call back before function
    |> Exrash.Report.add_record

    running_scenario(tail, before_func, after_func)
  end

  @doc """
  call request http client
  """
  def call_request(args, %{call_request: nil}), do: { :error, nil, nil }
  def call_request(args, %{call_request: call_request}), do: call_request.(args)

  @doc """
  call to scenario before function
  """
  @spec call_before_func(fun() | nil, { HTTPoison.Request.method(), HTTPoison.Request.url() | %URI{}, HTTPoison.Request.headers()})
            :: { HTTPoison.Request.method(), HTTPoison.Request.url() | %URI{}, HTTPoison.Request.headers() }
  def call_before_func(nil, args), do: args
  def call_before_func(func, args), do: func.(args)

  @doc """
  call to scenario after function
  """
  @spec call_after_func(fun() | nil, { HTTPoison.Response.t() | nil, DateTime.t() | nil, DateTime.t() | nil })
    ::  { HTTPoison.Response.t() | nil, DateTime.t() | nil, DateTime.t() | nil }
  def call_after_func(nil, args), do: args
  def call_after_func(func, args), do: func.(args)

  @doc """
  call to http request
  """
  def request_http(pid, request), do: GenServer.call(pid, {:request_http, request})

  @doc """
  call to async http request
  """
  def async_request_http(pid, request), do: GenServer.cast(pid, {:request_http, request})

  @doc """
  running worker process
  """
  @spec running_worker(pid()) :: :ok
  def running_worker(pid), do: GenServer.cast(pid, { :running })

  @doc """
  set worker config
  """
  @spec set_config(pid(), %WorkerConfig{}) :: { atom(), any() }
  def set_config(pid, %WorkerConfig{}=config), do: GenServer.call(pid, {:set_config, config})
end
