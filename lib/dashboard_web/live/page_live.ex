defmodule DashboardWeb.PageLive do
  use DashboardWeb, :live_view
  import Xlsxir
  require Logger

  def path(), do: "./lib/dashboard_web/live/xlsx/analisi_ivan.xlsx"
  def path_tullio(), do: "./lib/dashboard_web/live/xlsx/analisi_tullio.xlsx"

  def extract_sheet(sheet) do
    {:ok, s} = sheet
    info =
    get_info(s)

    [head | tail] = get_list(s)
    %{
      info: info,
      head: head,
      body: tail
    }
  end
  def mount(_params, _session, socket) do
    sheets = multi_extract(path_tullio())
    sheets = Enum.map(sheets, fn x -> extract_sheet(x) end)
    IO.inspect(sheets)
    {:ok, assign(
      socket,
      sheets: sheets,
      selected_tab: List.first(sheets).info[:name]
    )}
  end

  def handle_params(%{"tab" => tab} = _params, _url, socket) do
    {:noreply,
     assign(socket, selected_tab: tab)}
  end

  def handle_params(%{} = _params, _url, socket) do
    {:noreply, socket}
  end

end
