defmodule SensorHub.Sensor do
  defstruct [:fields, :read, :convert]
  
  def new(name) do 
    %__MODULE__{
      read: read_fn(name), 
      convert: convert_fn(name),
      fields: fields(name)
    }
  end
  
  def fields(SGP30), do: [:co2_eq_ppm, :tvoc_ppb]
  def fields(BMP280), do: [:altitude_m, :pressure_pa, :temperature_c]
  
  def read_fn(SGP30), do: fn -> SGP30.state() end
  def read_fn(BMP280), do: fn -> BMP280.read(BMP280) end
  def read_fn(module), do: fn -> module.measure() end
  
  def convert_fn(SGP30) do
    fn reading -> 
      Map.take(reading, [:co2_eq_ppm, :tvoc_ppb]) 
    end
  end
  def convert_fn(BMP280) do
    fn reading -> 
      case reading do
        {:ok, measurement} -> 
          Map.take(measurement, [:altitude_m, :pressure_pa, :temperature_c])
        _ -> %{}  
      end
    end
  end
  def convert_fn(_module) do
    fn data -> data end
  end
  
  def measure(sensor) do
    sensor.read.() |> sensor.convert.()
  end
end