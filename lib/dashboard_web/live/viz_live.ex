defmodule DashboardWeb.VizLive do
  use DashboardWeb, :live_view
  import Xlsxir
  require Logger
  def path(), do: "./lib/dashboard_web/live/xlsx/analisi_ivan.xlsx"
  def path_tullio(), do: "./lib/dashboard_web/live/xlsx/analisi_tullio.xlsx"

  def convert_to_struct(sheet) do
    [name, val, min, max, unit, tag, type] = sheet
    %{name: name, value: [Kernel.inspect(val)], min: min, max: max, unit: unit, tag: tag, type: type}
  end

  def extract_sheet(sheet, type) do
    {:ok, s} = sheet
    [_head | tail] = get_list(s)
    tail
    |> Enum.filter(fn t -> Enum.find(t, fn x -> x == type end) != nil end)
    |> Enum.map(fn x -> convert_to_struct(x) end)
  end

  def mount(_params, _session, socket) do

    sheets = multi_extract(path_tullio())
    labels = sheets
    |> Enum.map(fn {:ok, s} -> get_info(s) end)
    |> Enum.map(fn x -> x[:name] end)


    emocromo = sheets
    |> Enum.map(fn x -> extract_sheet(x, "Emocromo") end)
    |> Enum.concat
    |> Enum.group_by(&(&1.name))
    |> Enum.map(fn {_, [val | _] = vals} ->
      %{val | value: vals |> Enum.flat_map(&(&1.value))}
    end)

    immunometria = sheets
    |> Enum.map(fn x -> extract_sheet(x, "Chimica clinica e Immunometria") end)
    |> Enum.concat
    |> Enum.group_by(&(&1.name))
    |> Enum.map(fn {_, [val | _] = vals} ->
      %{val | value: vals |> Enum.flat_map(&(&1.value))}
    end)

    bilirubina = sheets
    |> Enum.map(fn x -> extract_sheet(x, "Bilirubina frazionata") end)
    |> Enum.concat
    |> Enum.group_by(&(&1.name))
    |> Enum.map(fn {_, [val | _] = vals} ->
      %{val | value: vals |> Enum.flat_map(&(&1.value))}
    end)

    {:ok, assign(
      socket,
      sheets: sheets,
      data: Jason.encode!(emocromo),
      raw: emocromo,
      immunometria_data: Jason.encode!(immunometria),
      immunometria_raw: immunometria,
      bilirubina_data: Jason.encode!(bilirubina),
      bilirubina_raw: bilirubina,
      labels: Jason.encode!(labels),
      selected_tab: "emocromo"
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
