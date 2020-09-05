defmodule DashboardWeb.HomeLive do
  use DashboardWeb, :live_view
  require Logger

  def path(), do: "./lib/dashboard_web/live/analisi_ivan.xlsx"
  def path_tullio(), do: "./lib/dashboard_web/live/analisi_tullio.xlsx"

  def mount(_params, _session, socket) do

    {:ok, assign(
      socket,
      selected_tab: "1"
    )}
  end



end
