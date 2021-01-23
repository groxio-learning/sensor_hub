defmodule SensorHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger
  use Application

  def start(_type, _args) do
    Logger.info(">>>>>>>>>>>>>>>>>>>>>>>>>>> Starting application >>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SensorHub.Supervisor]

    children =
      [
      ] ++ children(target())
    
    Logger.info(inspect children)

    Supervisor.start_link(children, opts)
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
      {Bme680, [[i2c_address: 0x77], [name: Bme680]]},
      {SGP30, []} 
    ]
  end

  def target() do
    Application.get_env(:sensor_hub, :target)
  end
end
