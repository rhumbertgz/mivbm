defmodule MIVBM do
  @moduledoc """
  Documentation for Mivbm.
  """
  require Logger
  alias MIVBM.VehicleMonitor
  @module Atom.to_string(__MODULE__) |> String.split_at(7) |> elem(1)

  @doc """
  Hello world.

  ## Examples

      iex> Mivbm.hello()
      :world

  """
  def monitor_lines(lines, observer, token) do
    Logger.debug("#{@module}.monitor_lines")

    lines
      |> Enum.split(10)
      |> Tuple.to_list()
      |> Enum.each(fn [] -> :ok ;
                      l  -> VehicleMonitor.monitor(l, observer, token)
                   end)
  end

  def monitor_stops(lines, observer, token) do
    # TODO
    {lines, observer, token}

  end

end
