defmodule SensorHub.Application do
  use Application
  alias SensorHub.Sensor

  def start(_type, _args) do
    System.cmd("epmd", ["-daemon"])
    [:hostname, host_name] = Application.get_env(:mdns_lite, :host)
    Node.start(:"hub@#{host_name}.local")

    opts = [strategy: :one_for_one, name: SensorHub.Supervisor]

    children =
      [] ++ children(target())

    Supervisor.start_link(children, opts)
  end
  
  defp sensors do
    [Sensor.new(BMP280), Sensor.new(VEML6030), Sensor.new(SGP30)]
  end
  
  defp broadcaster_pubsub do
    %{topic: "measurements", server: SensorHub.PubSub}
  end
  
  defp broadcaster do
    {Broadcaster, %{sensors: sensors(), pubsub: broadcaster_pubsub()}}
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: SensorHub.Worker.start_link(arg)
      # {SensorHub.Worker, arg},
    ]
  end

  def children(_target) do
    # These are sensors. They will fail on the host so let's start them only on targets.
    [
      {SGP30, []}, 
      {BMP280, [i2c_address: 0x77, name: BMP280]}, 
      {VEML6030, %{}}, 
      broadcaster(), 
      {Phoenix.PubSub.Supervisor, [name: SensorHub.PubSub]}
    ]
  end

  def target() do
    Application.get_env(:sensor_hub, :target)
  end
end
