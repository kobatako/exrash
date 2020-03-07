defmodule Exrash.MasterServer do

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    { :ok, %{ config: nil } }
  end

  @doc """
  """
  def handle_call({:start_request, config}, _from, state) do
    Exrash.MasterSup.create_worker(config.init_proc)
    Exrash.MasterSup.call_to_worker(config.http)

    spawn(__MODULE__, :interval, [config.interval_time, config.interval_count, config.add_proc, config.max_proc])
    { :reply, { :ok, :start_request }, %{ state| config: config } }
  end

  @doc """
  """
  def handle_cast({:call_request}, %{config: %{http: http}}=state) do
    Exrash.MasterSup.call_to_worker(http)
    {:noreply, state}
  end

  @doc """
  """
  def start_request(config) do
    with { :ok, :start_request } <- GenServer.call(__MODULE__, {:start_request, config})
    do
      { :ok, :start_request }
    else
      _ ->
        { :error, :not_request }
    end
  end

  @doc """
  not set interval time
  """
  def interval(interval_time, _, _, _) when interval_time <= -1 do
    Exrash.MasterSup.stop_call_request()
    { :error, "isn't valid interval time" }
  end
  def interval(0, _, _, _), do: { :ok, Exrash.MasterSup.stop_call_request() }
  def interval(_, 0, _, _), do: { :ok, Exrash.MasterSup.stop_call_request() }
  def interval(interval_time, interval_count, add_proc, max_proc) do
    Process.sleep(interval_time * 1000)

    with { :ok, num } <- Exrash.MasterSup.fetch_worker_count |> fetch_add_worker_num(add_proc, max_proc)
    do
      Exrash.MasterSup.create_worker(num)
      Exrash.Provider.call_request()

      interval(interval_time, interval_count - 1, add_proc, max_proc)
    else
      { :error, res } ->
        Exrash.MasterSup.stop_call_request()
        { :error, res }
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
end
