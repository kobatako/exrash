defmodule Exrash.Worker do

  use GenServer
  alias Exrash.HttpClient

  def start_link(pid) do
    GenServer.start_link(__MODULE__, [], name: {:global, pid})
  end

  def init(__init__) do
    {:ok, %{config: nil}}
  end

  @doc """
  """
  def handle_call({:request_http, %{"http" => http}}, _from, state) do
    res = HttpClient.get! http
    {:reply, res, state}
  end

  @doc """
  set config
  """
  def handle_call({:set_config, config}, _from, state) do
    {:reply, { :ok, :set_config }, %{ state | config: config }}
  end

  @doc """
  call http request
  """
  def handle_cast({:request_http, %{"http" => http}}, state) do
    { res, from, to } = call_request(http)
    Exrash.ResultReport.add_report(res, from, to)
    {:noreply, state}
  end

  @doc """
  running worker process
  worker process work to http request
  """
  def handle_cast({ :running }, %{ config: nil }=state), do: {:noreply, state}
  def handle_cast({ :running }, %{ config: %{ count: 0 } }=state), do: {:noreply, state}
  def handle_cast({ :running }, %{ config: config }=state) do
    IO.inspect "[Exrash][Worker] handle_cast : running"
    IO.inspect config
    IO.inspect config.http
    call_request(config.http)
    |> Exrash.ResultReport.add_report

    Process.sleep(config.sleep * 1000)
    Exrash.Worker.running_worker(self)
    { :noreply, %{ state| config: %{ config| count: config.count - 1 }}}
  end

  @doc """
  """
  def call_request(http) do
    IO.inspect "[Exrash][Worker] call_request"
    IO.inspect http
    from = Timex.now
    res = HttpClient.get! http
    to = Timex.now
    {res, from, to}
  end

  @doc """
  call to http request
  """
  def request_http(pid, request) do
    GenServer.call(pid, {:request_http, request})
  end

  @doc """
  call to async http request
  """
  def async_request_http(pid, request) do
    GenServer.cast(pid, {:request_http, request})
  end

  @doc """
  """
  def running_worker(pid) do
    GenServer.cast(pid, { :running })
  end

  @doc """
  """
  def set_config(pid, config) do
    GenServer.call(pid, {:set_config, config})
  end
end
