defmodule Exrash.Exporter.IOExporter do
  @moduledoc """
  IO exporter
  """

  use GenServer
  @behavior Exrash.Exporter.ExporterBehaviour

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    { :ok, %{} }
  end

  def handle_cast({ :export_record, res }, state) do
    IO.inspect res
    { :noreply, state }
  end

  @impl ExporterBehaviour
  def export(record) do
    GenServer.cast(__MODULE__, { :export_record, record })
  end
end
