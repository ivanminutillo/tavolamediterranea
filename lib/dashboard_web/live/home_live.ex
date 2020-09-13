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

  def nutritional_value(sheet, value) do
    sheet
      |> Enum.map(fn x -> x[value] end)
      |> Enum.sum()
  end


  def extract_nutrition(sheet) do
    [h | t] = sheet.list
    t
    |> Enum.map(fn x ->
      [name, per, kcal, grassi, saturated, carbo, sugar, protein, salt, fiber, q] = x
      %{name: name, kcal: kcal / per * q |> Float.ceil(2)   , grassi: String.to_float(grassi) / per * q |> Float.ceil(2)  , saturated: String.to_float(saturated) / per * q |> Float.ceil(2)  , carbo: String.to_float(carbo) / per * q |> Float.ceil(2)  , sugar: String.to_float(sugar) / per * q |> Float.ceil(2)  , protein: String.to_float(protein) / per * q |> Float.ceil(2)  , salt: String.to_float(salt) / per * q |> Float.ceil(2)  , fiber: String.to_float(fiber) / per * q |> Float.ceil(2)  , q: q}
    end)

  end

  def mount(_params, _session, socket) do
    sheets = multi_extract(path())
    sheets = Enum.map(sheets, fn x -> extract_sheet(x) end)

    day = sheets
    |> Enum.find(fn x -> x[:name] === "giornata tipo" end)
    |> extract_nutrition()
    IO.inspect(day)

    diet = sheets
    |> Enum.find(fn x -> x[:name] === "Programma alimentare" end)
    |> convert_diet()
    {:ok, assign(
      socket,
      misure: sheets
      |> Enum.find(fn x -> x[:name] === "Misure antropometriche" end)
      |> Jason.encode!,
      diet: diet,
      day: day,
      kcal: nutritional_value(day, :kcal) |> Float.ceil(2) ,
      fat: nutritional_value(day, :grassi) |> Float.ceil(2) ,
      carb: nutritional_value(day, :carbo) |> Float.ceil(2) ,
      protein: nutritional_value(day, :protein) |> Float.ceil(2) ,
      fiber: nutritional_value(day, :fiber) |> Float.ceil(2) ,
      sugar: nutritional_value(day, :sugar) |> Float.ceil(2)
      # colatione: colazione
      # spuntino: spuntino
      # principale: principale
    )}
  end



end
