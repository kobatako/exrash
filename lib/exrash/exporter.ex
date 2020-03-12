defmodule Exrash.Exporter do

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(__init__) do
    { :ok, %{} }
  end

  def handle_cast({ :export_log, res }, state) do
    IO.inspect res
    { :noreply, state }
  end
end
