defmodule DashboardWeb.HomeLive do
  use DashboardWeb, :live_view
  require Logger
  import Xlsxir

  def path(), do: "./lib/dashboard_web/live/xlsx/dieta.xlsx"

  def convert_to_struct(sheet) do
    [name, amount, unit, times, type] = sheet
    %{name: name, amount: amount, unit: unit, times: times, type: type}
  end



  @spec extract_sheet({:ok, atom | :ets.tid()}) :: %{list: [any], name: any}
  def extract_sheet(sheet) do
    {:ok, s} = sheet
    info = get_info(s)
    list = get_list(s)
    %{
      name: info[:name],
      list: list
    }
  end

  def convert_diet(sheet) do
    [_h | t] = sheet.list
    diet = t
    |> Enum.map(fn x -> convert_to_struct(x) end)
    |> Enum.group_by(&(&1.name)) # groups as specified
    |> Enum.map(fn {name, data} ->
      # do the magic to sum up prices
      calculated_sum = data
      |> Enum.map(fn x ->
        %{
          name: x[:name],
          amount: x[:amount] * x[:times],
          type: x[:type],
          unit: x[:unit]
        }
      end)
      |> Enum.map(fn x -> x[:amount] end)
      |> Enum.sum()

      %{name: name, amount: calculated_sum, unit: List.first(data)[:unit]}
    end)
  end


  def mount(_params, _session, socket) do
    sheets = multi_extract(path())
    sheets = Enum.map(sheets, fn x -> extract_sheet(x) end)
    diet = sheets
    |> Enum.find(fn x -> x[:name] === "Programma alimentare" end)
    |> convert_diet()
    IO.inspect(diet)
    {:ok, assign(
      socket,
      misure: sheets
      |> Enum.find(fn x -> x[:name] === "Misure antropometriche" end)
      |> Jason.encode!,
      diet: diet,
      # colatione: colazione
      # spuntino: spuntino
      # principale: principale
    )}
  end



end
