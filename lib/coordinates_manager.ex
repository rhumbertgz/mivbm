defmodule MIVBM.CoordinatesManager do
  require Logger
  alias MIVBC.VehiclePosition
  @module Atom.to_string(__MODULE__) |> String.split_at(7) |> elem(1)

  def load_coordinates(line) do
    case :file.consult("coordinates/line-#{line}.lc") do
        {:ok, [coordinates]} -> coordinates
        _               -> %{}
    end
  end

  def get_coordinates_by_line(coordinates,line, %VehiclePosition{ directionId: direction, pointId: point, distanceFromPoint: 0}) do
    Logger.debug("#{@module}.get_coordinates_by_line line: #{inspect line} direction: #{inspect direction} point: #{inspect point} distance: 0")
    stop = coordinates
      |> Map.get(line)
      |> Map.get(direction)
      |> Map.get(point)
      |> elem(0)
    %{coordinates: stop, type: 0, capacity: 0}
  end

  def get_coordinates_by_line(coordinates, line, %VehiclePosition{ directionId: direction, pointId: point, distanceFromPoint: distance}) do
    Logger.debug("#{@module}.get_coordinates_by_line line: #{inspect line} direction: #{inspect direction} point: #{inspect point} distance: #{inspect distance}")
    stop = coordinates
      |> Map.get(line)
      |> Map.get(direction)
      |> Map.get(point)
      |> elem(1)
    %{coordinates: stop, type: 1, capacity: 0}
  end
end
