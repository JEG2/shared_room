defmodule SharedRoom do
  @moduledoc """
  Starter application using the Scenic framework.
  """

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:shared_room, :viewport)
    cells =
      main_viewport_config
      |> Map.fetch!(:size)
      |> SharedRoom.Grid.pixels_to_cells

    # start the application with the viewport
    children = [
      {SharedRoom.Room, cells},
      supervisor(Scenic, viewports: [main_viewport_config])
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
