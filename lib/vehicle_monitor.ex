defmodule MIVBM.VehicleMonitor do
  @moduledoc """
  Documentation for Mivbm.
  """
  use GenServer
  require Logger
  alias MIVBC.VehiclePositionByLine.Line
  @module Atom.to_string(__MODULE__) |> String.split_at(7) |> elem(1)

  @spec monitor(any(), any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def monitor(lines, token) do
    GenServer.start_link(__MODULE__, {lines, token})
  end

  @impl true
  def init(args) do
    {:ok, args, {:continue, :init}}
  end

  @impl true
  def handle_continue(:init, {lines, token}) do
    LineAgent.start_link()
    pull_mivb_api(lines, token)
    {:noreply, {lines, token}}
  end

  @impl true
  def handle_info(:update_position, {lines, token}) do
    pull_mivb_api(lines, token)
    {:noreply, {lines, token}}
  end

  defp pull_mivb_api(lines, token) do
    response = MIVBC.vehicle_position_by_Line(lines, token)
    schedule_next_update()
    update_vehicle_positions(response)
  end

  defp update_vehicle_positions({:error, reason}) do
    Logger.debug("#{@module}.update_vehicle_positions")
    Logger.error("Error: #{reason}")
  end

  defp update_vehicle_positions([%Line{ lineId: 0}| []]) do
    Logger.error("#{@module}.update_vehicle_positions - Open-Data API Connection Error")
  end

  defp update_vehicle_positions(response) do
    Enum.each(response, fn l ->
      Enum.each(l.vehiclePositions, fn v ->LineAgent.log(v)end)
    end)

  end

  defp schedule_next_update do
    Logger.debug("#{@module}.schedule_next_update")
    Process.send_after(self(), :update_position, 10_000) # 10 sec
  end

end
