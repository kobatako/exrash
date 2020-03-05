defmodule Exrash.Worker do

  use GenServer
  alias Exrash.HttpClient

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
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
