defmodule MIVBM.VehicleMonitor do
  @moduledoc """
  Documentation for Mivbm.
  """
  use GenServer
  require Logger
  alias MIVBC.VehiclePositionByLine.Line
  alias MIVBM.CoordinatesManager


  def monitor(lines, token, observer) do
    GenServer.start_link(__MODULE__, {lines, token, observer})
  end

  @impl true
  def init(args) do
    {:ok, args, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, {lines, token, observer}) do
    coordinates = Enum.reduce(lines, %{}, fn line, acc ->
      Map.put_new(acc, Integer.to_string(line), CoordinatesManager.load_coordinates(line))
    end)

    pull_mivb_api(lines, token, observer, coordinates)
    {:noreply, {lines, token, observer, coordinates}}
  end

  @impl true
  def handle_info(:update_position, {lines, token, observer, coordinates}) do
    pull_mivb_api(lines, token, observer, coordinates)
    {:noreply, {lines, token, observer, coordinates}}
  end

  defp pull_mivb_api(lines, token, observer, coordinates) do
    response = MIVBC.vehicle_position_by_Line(lines, token)
    schedule_next_update()
    update_vehicle_positions(response, observer, coordinates)
  end

  defp update_vehicle_positions({:error, reason}, _observer, _coordinates) do
    Logger.error("update_vehicle_positions - Reason: #{reason}")
  end

  defp update_vehicle_positions([%Line{ lineId: 0}| []], _observer, _coordinates) do
    Logger.error("update_vehicle_positions - Open-Data API Connection Error")
  end

  defp update_vehicle_positions(response, observer, coordinates) do
    positions = Enum.map(response,
	                        fn l ->
	                          %{line: l.lineId,
	                            vehicles: Enum.map(l.vehiclePositions,
	                                            fn v ->
	                                              MIVBM.CoordinatesManager.get_coordinates_by_line(coordinates, l.lineId, v)
	                                            end)
	                          }
	                        end)
	    Logger.debug("update_vehicle_positions - #{inspect positions}")
	    GenServer.cast(observer, {:update_vehicle_positions, positions})

  end

  defp schedule_next_update do
    Process.send_after(self(), :update_position, 10_000) # 10 sec
  end

end
