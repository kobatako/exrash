defmodule Exrash.MasterServer do

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    { :ok, %{ master_config: nil, worker_config: nil } }
  end

  @doc """
  request to http call
  create worker and interval http request
  """
  def handle_call({:start_http_request, config}, _from, state) do
    create_worker(config.init_proc)
    call_to_worker(config.http)

    spawn(__MODULE__, :interval, [
      config.interval_time, config.interval_count,
      fn args -> args |> call_to_http_request end,
      { config.add_proc, config.max_proc }
    ])
    { :reply, { :ok, :start_http_request }, %{ state| config: config } }
  end

  @doc """
  call request for worker process
  """
  def handle_cast({:call_http_request}, %{config: %{http: http}}=state) do
    call_to_worker(http)
    {:noreply, state}
  end

  @doc """
  """
  def handle_cast({:call_request}, %{config: %{http: http}}=state) do
    call_to_worker(http)
    {:noreply, state}
  end

  @doc """
  """
  def handle_cast({:start_worker_process, master_config, worker_config}, state) do
    with { :ok, workers } <- create_worker(master_config.init_proc)
    do
      workers |> start_workers(worker_config)
      spawn(__MODULE__, :interval, [
        master_config.interval_time, master_config.interval_count,
        fn args -> args |> call_to_start_worker end,
        { master_config.add_proc, master_config.max_proc, worker_config }
      ])
      { :noreply, { :ok, :start_http_request }, %{ state| master_config: master_config, worker_config: worker_config } }
    else
      _ ->
        { :noreply, { :error, :start_http_request }, state }
    end
  end

  def terminate(reason, _state) do
    {:shutdown, "terminate master server"}
  end

  @doc """
  """
  def set_provider_config(config), do: GenServer.call(__MODULE__, { :set_provider, config })

  @doc """
  """
  def start_http_request(config) do
    with { :ok, :start_http_request } <- GenServer.call(__MODULE__, {:start_http_request, config})
    do
      { :ok, :start_http_request }
    else
      _ ->
        { :error, :not_request }
    end
  end

  @doc """
  """
  def start_worker_process(master_config, worker_config) do
    GenServer.cast(__MODULE__, { :start_worker_process, master_config, worker_config })
  end

  @doc """
  call request to worker
  """
  def call_to_start_worker({ add_proc, max_proc, config }) do
    with { :ok, num } <- fetch_worker_count |> fetch_add_worker_num(add_proc, max_proc),
       {:ok, workers }  <- create_worker(num)
    do
      start_workers(workers, config)
      { :ok }
    else
      { :error, res } ->
        stop_call_request()
        { :error, res }
    end
  end

  @doc """
  call request to worker
  """
  def call_to_http_request({ add_proc, max_proc }) do
    with { :ok, num } <- fetch_worker_count |> fetch_add_worker_num(add_proc, max_proc)
    do
      create_worker(num)
      call_request()
      { :ok }
    else
      { :error, res } ->
        stop_call_request()
        { :error, res }
    end
  end

  @doc """
  not set interval time
  """
  def interval(interval_time, _, _, _) when interval_time <= -1 do
    stop_call_request()
    { :error, "isn't valid interval time" }
  end
  def interval(0, _, _, _), do: { :ok, stop_call_request() }
  def interval(_, 0, _, _), do: { :ok, stop_call_request() }
  def interval(interval_time, interval_count, interval_func, args) do
    Process.sleep(interval_time * 1000)
    with { :ok } <- interval_func.(args)
    do
      interval(interval_time, interval_count - 1, interval_func, args)
    else
      _ ->
        { :error, :interval }
    end
  end

  @doc """
  get add worker number
  """
  defp fetch_add_worker_num(_, add_proc, nil) when is_integer(add_proc), do: { :ok, add_proc }
  defp fetch_add_worker_num(current, add_proc, max_proc) when not is_integer(current) or not is_integer(add_proc) or not is_integer(max_proc) do
    {:error, "is not type"}
  end
  defp fetch_add_worker_num(current, add_proc, max_proc) when current <= 0 or add_proc <= 0 or max_proc <= 0 do
    {:error, "is not type"}
  end
  defp fetch_add_worker_num(current, _, max_proc) when max_proc <= current, do: { :ok, 0 }
  defp fetch_add_worker_num(current, add_proc, max_proc) when (max_proc - current) >= add_proc, do: { :ok, add_proc }
  defp fetch_add_worker_num(current, _, max_proc), do: {:ok, max_proc - current }

  @doc """
  create worker process
  """
  def create_worker(count) when not is_integer(count), do: { :error, "not type count" }
  def create_worker(count) when count < 0, do: { :error, "don't create count" }
  def create_worker(count) do
    res = for _ <- 1..count, do: Exrash.WorkerSup.create_worker
    { :ok, res }
  end

  @doc """
  call to http request for worker sup
  """
  def call_to_worker(http), do: Exrash.WorkerSup.call_http_request(http)

  @doc """
  fetch current worker process number
  """
  def fetch_worker_count(), do: Exrash.WorkerSup.fetch_worker_count

  @doc """
  call request
  """
  def call_request(), do: GenServer.cast(__MODULE__, { :call_request })

  @doc """
  """
  def stop_call_request(), do: { :ok }

  @doc """
  """
  def start_workers({:ok, workers}, config) do
    workers
    |> Enum.map(&(Exrash.WorkerSup.start_worker(&1, config)))
  end
  def start_workers(workers, config) do
    workers
    |> Enum.map(&(Exrash.WorkerSup.start_worker(&1, config)))
  end
end
