defmodule Exrash.Worker do

  use GenServer
  alias Exrash.HttpClient

  def start_link(pid) do
    GenServer.start_link(__MODULE__, [], name: {:global, pid})
  end

  def init(stack) do
    {:ok, stack}
  end

  def handle_call({:request_http, %{"http" => http}}, _from, state) do
    res = HttpClient.get! http
    {:reply, res, state}
  end

  def handle_cast({:request_http, %{"http" => http}}, state) do
    res = HttpClient.get! http
    {:noreply, state}
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
end
