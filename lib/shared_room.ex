defmodule SharedRoom do
  @moduledoc """
  Starter application using the Scenic framework.
  """

  def start(_type, _args) do
    # load the viewport configuration from config
    main_viewport_config = Application.get_env(:shared_room, :viewport)

    Supervisor.start_link(
      children(System.argv, main_viewport_config),
      strategy: :one_for_one
    )
  end

  defp children(["HOST"], main_viewport_config) do
    cells =
      main_viewport_config
      |> Map.fetch!(:size)
      |> SharedRoom.Grid.pixels_to_cells

    [
      {SharedRoom.Room, cells},
      scenic_child(main_viewport_config)
    ]
  end
  defp children([address], main_viewport_config) do
    Node.connect(String.to_atom(address))
    wait_for_connection()
    [
      scenic_child(main_viewport_config)
    ]
  end
  defp children(_args, _main_viewport_config) do
    IO.puts "See README"
    System.halt
  end

  defp scenic_child(main_viewport_config) do
    import Supervisor.Spec, warn: false

    # start the application with the viewport
    supervisor(Scenic, viewports: [main_viewport_config])
  end

  defp wait_for_connection do
    Process.sleep(100)
    if Node.list == [ ] do
      wait_for_connection()
    end
  end
end
