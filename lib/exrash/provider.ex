defmodule Exrash.Provider do
  @moduledoc """
  exrash provider.
  provide config and message to master process.
  """

  use GenServer

  alias __MODULE__
  alias Exrash.Worker.WorkerConfig
  alias Exrash.Master.MasterConfig

  defstruct master_config: %MasterConfig{}, worker_config: %WorkerConfig{}

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    { :ok, %{ config: nil } }
  end

  @spec new(map()) :: %Provider{}
  def new(config) do
    config
    |> Map.merge(%{worker_config: new_worker_config(config)})
    |> Map.merge(%{master_config: new_master_config(config)})
    |> (&(Map.merge(%Provider{}, &1))).()
  end

  @doc """
  make to worker config from map.
  """
  def new_worker_config(%{worker_config: config}), do: WorkerConfig.new(config)
  def new_worker_config(_), do: WorkerConfig.new()

  @doc """
  make to master config from map.
  """
  def new_master_config(%{master_config: config}), do: MasterConfig.new(config)
  def new_master_config(_), do: MasterConfig.new()

  @doc """
  """
  def handle_call({:set_provider_config, config}, _from, state) do
    re_state = %{ state| config: config }
    {:reply, re_state, re_state}
  end

  @doc """
  """
  def handle_cast({:start_request}, %{config: nil}=state) do
    {:noreply, state}
  end

  @doc """
  call to start http request
  """
  def handle_cast({:start_http_request}, %{config: config}=state) do
    Exrash.MasterSup.start_http_request(config.master_config)
    {:noreply, state}
  end

  @doc """
  call to start worker process, bad config is set null.
  """
  def handle_cast({:start_worker_process}, %{config: nil}=state) do
    {:noreply, state}
  end

  @doc """
  call to start worker process.
  """
  def handle_cast({:start_worker_process}, %{config: config}=state) do
    Exrash.MasterSup.start_worker_process(config.master_config, config.worker_config)
    {:noreply, state}
  end

  @doc """
  stop worker process
  """
  def handle_cast({:stop_worker_process}, state) do
    Exrash.MasterSup.stop_worker_process()
    {:noreply, state}
  end

  def terminate(reason) do
    { :shutdown, "terminate provider" }
  end

  @doc """
  start request
  """
  def start_http_request(), do: GenServer.cast(Exrash.Provider, { :start_http_request })

  @doc """
  call request
  """
  def call_request(), do: GenServer.cast(Exrash.Provider, { :call_request })

  @doc """
  set config
  """
  def set_provider_config(config), do: GenServer.call(Exrash.Provider, { :set_provider_config, config })

  @doc """
  start worker process
  """
  def start_worker_process(), do: GenServer.cast(Exrash.Provider, { :start_worker_process })

  @doc """
  stop worker process
  """
  def stop_worker_process(), do: GenServer.cast(Exrash.Provider, { :stop_worker_process })
end
