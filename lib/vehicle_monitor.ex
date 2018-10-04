defmodule MIVBM.VehicleMonitor do
  @moduledoc """
  Documentation for Mivbm.
  """
  use GenServer
  require Logger
  alias MIVBM.CoordinatesManager
  @module Atom.to_string(__MODULE__) |> String.split_at(7) |> elem(1)

  @doc """


  ## Examples

      iex> Mivbm.
      :world

  """
  def monitor(lines, broker, token) do
    GenServer.start_link(__MODULE__, {lines, broker, token})
  end

  @impl true
  def init(args) do
    {:ok, args, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, {lines, broker, token}) do
    coordinates = Enum.reduce(lines, %{}, fn line, acc ->
                    Map.put_new(acc, Integer.to_string(line), CoordinatesManager.load_coordinates(line))
                  end)

    Logger.debug("#{@module}.handle_continue coordinates: #{inspect coordinates}")
    MIVBC.start()
    response = MIVBC.vehicle_position_by_Line(lines, token)
    Logger.debug("#{@module}.handle_continue response: #{inspect response}")
    schedule_next_update()
    update_vehicle_positions(broker, response, coordinates)
    {:noreply, {lines, broker, token, coordinates}}
  end



  @impl true
  def handle_info(:update_position, {lines, broker, token, coordinates}) do
    response = MIVBC.vehicle_position_by_Line(lines, token)
    Logger.debug("#{@module}.update_position response: #{inspect response}")
    schedule_next_update()
    update_vehicle_positions(broker, response, coordinates)
    {:noreply, {lines, broker, token, coordinates}}
  end

  defp update_vehicle_positions(_broker, {:error, reason}, _coordinates) do
    Logger.debug("#{@module}.update_vehicle_positions")
    Logger.error("Error: #{reason}")
  end

  [%MIVBC.Line{ lineId: 0}| []]

  defp update_vehicle_positions(broker, [%MIVBC.Line{ lineId: 0}| []], _coordinates) do
    Logger.error("#{@module}.update_vehicle_positions - Open-Data API Connection Error")
  end

  defp update_vehicle_positions(broker, response, coordinates) do
    positions = Enum.map(response,
                        fn l ->
                          %{line: l.lineId,
                            vehicles: Enum.map(l.vehiclePositions,
                                            fn v ->
                                              MIVBM.CoordinatesManager.get_coordinates_by_line(coordinates, l.lineId, v)
                                            end)
                          }
                        end)
    Logger.debug("#{@module}.update_vehicle_positions - #{inspect positions}")
    GenServer.cast(broker, {:update_vehicle_positions, positions})
  end

  defp schedule_next_update do
    Logger.debug("#{@module}.schedule_next_update")
    Process.send_after(self(), :update_position, 20_000) # 20 sec
  end

end
