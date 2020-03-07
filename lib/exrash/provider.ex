defmodule Exrash.Provider do

  if Mix.env == :test do
    @compile :export_all
    @compile :nowarn_export_all
  end

  use GenServer

  defstruct http: "", init_proc: 0, add_proc: 0, max_proc: nil, interval_count: 0, interval_time: nil

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(state) do
    { :ok, %{ config: nil } }
  end

  @doc """
  """
  def handle_call({:set_state, config}, _from, state) do
    re_state = %{ state| config: config }
    {:reply, re_state, re_state}
  end

  @doc """
  """
  def handle_cast({:start_request}, %{config: nil}=state) do
    IO.inspect "[error] not set config"
    {:noreply, state}
  end

  @doc """
  """
  def handle_cast({:start_request}, %{config: %{http: http}=config}=state) do
    Exrash.MasterSup.start_request(config)
    {:noreply, state}
  end

  @doc """
  """
  def handle_cast({:call_request}, %{config: %{http: http}}=state) do
    Exrash.MasterSup.call_to_worker(http)
    {:noreply, state}
  end

  @doc """
  start request
  """
  def start_request(), do: GenServer.cast(Exrash.Provider, {:start_request})

  @doc """
  call request
  """
  def call_request(), do: GenServer.cast(Exrash.Provider, {:call_request})

  @doc """
  set config
  """
  def set_configure(config) do
    GenServer.call(Exrash.Provider, {:set_state, config})
  end
end
