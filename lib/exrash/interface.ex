defmodule Exrash.Interface do
  @moduledoc """
  Exrash interface
  provide configure, start process and more
  """

  alias Exrash.Provider

  @doc """
  """
  def set_configure(config) do
    Provider.new(config)
    |> Exrash.Provider.set_provider_config
  end

  @doc """
  """
  def start() do
    Exrash.Provider.start_worker_process()
  end

  def stop() do
    Exrash.Provider.stop_worker_process()
  end
end
