defmodule MIVBM do
  @moduledoc """
  Documentation for Mivbm.
  """
  require Logger
  alias MIVBM.VehicleMonitor

  @doc """
  Monitor a list of lines and notify updates to the observer_pid

  ## Examples

      iex> MIVBM.monitor_lines [1,5], my_token, observer_pid
      :world

  """
  def monitor_lines(lines, token, observer) do
    Logger.debug("monitor_lines #{inspect lines}")

    lines
      |> Enum.split(10)
      |> Tuple.to_list()
      |> Enum.each(fn [] -> :ok ;
                      l  -> VehicleMonitor.monitor(l, token, observer)
                   end)
  end

  def monitor_stops(lines, token, observer) do
    # TODO
    {lines, token, observer}

  end

end
