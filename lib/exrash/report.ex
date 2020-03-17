defmodule Exrash.Report do
  @moduledoc """
  report response data.
  """

  use GenServer

  alias Exrash.Report.Record
  alias Exrash.Exporter.ExporterBehaviour

  defstruct records: [], exporter: nil

  @type t() :: %__MODULE__{
    records: list(%Record{}),
    exporter: ExporterBehaviour.t()
  }

  def start_link(exporter \\ nil) do
    GenServer.start_link(__MODULE__, { exporter }, name: __MODULE__)
  end

  def init({ exporter }) do
    {:ok, %Exrash.Report{ exporter: exporter }}
  end

  def handle_cast({:add_record, { result, from, to }}, state) do
    res = Record.new(result, from, to)
    export_record(state.exporter, res)
    {:noreply, %Exrash.Report{state | records: [res| state.records]}}
  end

  def handle_call({:get_records, nil}, _from, state) do
    {:reply, state.records |> sort_record, state}
  end

  def handle_call({:get_records, fetch_state}, _from, state) do
    {:reply, filter(fetch_state, state.records) |> sort_record, state}
  end

  @doc """
  response export record
  """
  def export_record(nil, res), do: { :ok }
  def export_record(exporter, res), do: GenServer.cast(exporter, { :export_record, res })

  @doc """
  add response record
  """
  def add_record({res, from, to}), do: GenServer.cast(__MODULE__, {:add_record, { res, from, to }})
  def add_record(res, from, to), do: GenServer.cast(__MODULE__, {:add_record, { res, from, to }})

  @doc """
  get log record
  """
  def get_records(), do: GenServer.call(__MODULE__, {:get_records, nil})
  def get_records(fetch_state), do: GenServer.call(__MODULE__, {:get_records, fetch_state})

  @doc """
  sort reacord
  """
  defp sort_record(records), do: sort_record(records, :desc)
  defp sort_record(records, :desc), do: Enum.sort(records, fn a, b -> a.start >= b.start end)
  defp sort_record(records, :asc), do: Enum.sort(records, fn a, b -> a.start <= b.start end)

  @doc """
  record filter
  """
  defp filter([], res), do: res
  defp filter(_, []), do: []
  defp filter([{:from, from} | filters], records) do
    res = Enum.filter(records, fn record -> record.start >= from end)
    filter(filters, res)
  end
  defp filter([{:to, to} | filters], records) do
    res = Enum.filter(records, fn record -> record.start <= to end)
    filter(filters, res)
  end
  defp filter([{:limit, {limit, :head}} | filters], records) do
    res = records
    |> sort_record
    |> limit_number(limit, [])
    filter(filters, res)
  end
  defp filter([{:limit, {limit, :tail}} | filters], records) do
    res = records
    |> sort_record(:asc)
    |> limit_number(limit, [])
    filter(filters, res)
  end

  @doc """
  fetch limit record
  """
  defp limit_number([], _, res), do: res
  defp limit_number(_, 0, res), do: res
  defp limit_number([head| tail], limit, res), do: limit_number(tail, limit - 1, [head| res])
end
