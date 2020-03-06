defmodule Exrash.Worker do

  use GenServer
  alias Exrash.HttpClient

  def start_link(pid) do
    IO.inspect pid
    GenServer.start_link(__MODULE__, [], name: {:global, pid})
  end

  def init(stack) do
    HttpClient.start
    {:ok, stack}
  end

  def handle_call({:request_http, %{"http" => http}}, _from, state) do
    res = HttpClient.get! http
    {:reply, res, state}
  end

  @doc """
  call to http request
  """
  def request_http(request) do
    GenServer.call(__MODULE__, {:request_http, request})
  end
end
