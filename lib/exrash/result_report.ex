defmodule Exrash.ResultReport do
  @moduledoc """

  """

  use GenServer

  defstruct report: []

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    {:ok, %Exrash.ResultReport{}}
  end

  def handle_cast({:add_report, { result, from, to }}, state) do
    res = Exrash.ReportLog.new(result, from, to)
    {:noreply, %Exrash.ResultReport{state | report: [res| state.report]}}
  end

  def handle_call({:get_logs, nil}, _from, state) do
    {:reply, state.report |> sort_log, state}
  end

  def handle_call({:get_logs, fetch_state}, _from, state) do
    {:reply, filter(fetch_state, state.report) |> sort_log, state}
  end

  @doc """
  """
  def add_report({res, from, to}), do: GenServer.cast(Exrash.ResultReport, {:add_report, { res, from, to }})
  def add_report(res, from, to), do: GenServer.cast(Exrash.ResultReport, {:add_report, { res, from, to }})

  @doc """
  """
  def get_logs(), do: GenServer.call(Exrash.ResultReport, {:get_logs, nil})
  def get_logs(fetch_state), do: GenServer.call(Exrash.ResultReport, {:get_logs, fetch_state})

  @doc """
  """
  defp sort_log(reports), do: sort_log(reports, :desc)
  defp sort_log(reports, :desc), do: Enum.sort(reports, fn a, b -> a.start >= b.start end)
  defp sort_log(reports, :asc), do: Enum.sort(reports, fn a, b -> a.start <= b.start end)

  @doc """
  """
  defp filter([], res), do: res
  defp filter(_, []), do: []
  defp filter([{:from, from} | filters], reports) do
    res = Enum.filter(reports, fn report -> report.start >= from end)
    filter(filters, res)
  end
  defp filter([{:to, to} | filters], reports) do
    res = Enum.filter(reports, fn report -> report.start <= to end)
    filter(filters, res)
  end
  defp filter([{:limit, {limit, :head}} | filters], reports) do
    res = reports
    |> sort_log
    |> limit_number(limit, [])
    filter(filters, res)
  end
  defp filter([{:limit, {limit, :tail}} | filters], reports) do
    res = reports
    |> sort_log(:asc)
    |> limit_number(limit, [])
    filter(filters, res)
  end

  @doc """
  """
  defp limit_number([], _, res), do: res
  defp limit_number(_, 0, res), do: res
  defp limit_number([head| tail], limit, res) do
    limit_number(tail, limit - 1, [head| res])
  end
end
