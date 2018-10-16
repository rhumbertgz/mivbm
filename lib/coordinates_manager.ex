defmodule MIVBM.CoordinatesManager do
  require Logger
  alias MIVBC.VehiclePosition
  @module Atom.to_string(__MODULE__) |> String.split_at(7) |> elem(1)

  def load_coordinates(line) do
    case :file.consult("coordinates/line-#{inspect line}.lc") do
        {:ok, [coordinates]} -> coordinates
        _               -> %{}
    end
  end

  def get_coordinates_by_line(coordinates,line, %VehiclePosition{ directionId: direction, pointId: point, distanceFromPoint: 0}) do
    Logger.debug("#{@module}.get_coordinates_by_line line: #{inspect line} direction: #{inspect direction} point: #{inspect point} distance: 0")
    {coord , _, _} = coordinates
      |> Map.get(line, %{})
      |> Map.get(direction, %{})
      |> Map.get(point, {[0,0],0,0})
    log_missing_stop(coord, line, direction, point, 0)
    %{coordinates: coord, type: 1, capacity: 0}
  end

  def get_coordinates_by_line(coordinates, line, %VehiclePosition{ directionId: direction, pointId: point, distanceFromPoint: distance}) do
    Logger.debug("#{@module}.get_coordinates_by_line line: #{inspect line} direction: #{inspect direction} point: #{inspect point} distance: #{inspect distance}")
    {_ , coord, type} = coordinates
    |> Map.get(line, %{})
      |> Map.get(direction, %{})
      |> Map.get(point, {0,[0,0],0})
    log_missing_stop(coord, line, direction, point, distance)
    %{coordinates: coord, type: type, capacity: 0}
  end


  def log_missing_stop([0,0], line, direction, point, distance) do
    content = :io_lib.format("~tp.~n", ["line: #{inspect line} direction: #{inspect direction} point: #{inspect point} distance: #{inspect distance}"])
    :file.write_file("logs/dm#{System.monotonic_time}.lc", content)
  end
  def log_missing_stop(_,_,_,_,_) do
    :ok
  end
end
