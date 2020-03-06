defmodule Exrash.Provider do

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    {:ok, %{config: nil}}
  end

  def handle_call({:set_state, config}, _from, state) do
    re_state = %{state| config: config}
    {:reply, re_state, re_state}
  end

  def handle_cast({:start_request}, %{config: nil}=state) do
    IO.inspect "[error] not set config"
    {:noreply, state}
  end

  def handle_cast({:start_request}, %{config: %{"worker" => %{count: count}, "http" => http}}=state) do
    Exrash.MasterSup.create_worker(count)
    Exrash.MasterSup.call_to_worker(http)

    {:noreply, state}
  end

  def start_request() do
    GenServer.cast(Exrash.Provider, {:start_request})
  end

  def set_configure(config) do
    GenServer.call(Exrash.Provider, {:set_state, config})
  end
end
