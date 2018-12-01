defmodule SharedRoom.Room do
  use GenServer
  alias SharedRoom.Scene.Home
  alias SharedRoom.Grid

  defstruct size: nil,
            next_player: 1,
            player_scenes: %{ },
            locations: %{ }

  def start_link(size) do
    GenServer.start_link(__MODULE__, size, name: {:global, __MODULE__})
  end

  def register_scene(scene) do
    GenServer.call({:global, __MODULE__}, {:register_scene, scene})
  end

  def move(scene, direction) do
    GenServer.cast({:global, __MODULE__}, {:move, scene, direction})
  end

  def init(size) do
    {:ok, %__MODULE__{size: size}}
  end

  def handle_call({:register_scene, scene}, _from, state) do
    name = String.to_atom("player_#{state.next_player}")
    location = starting_location(state.size, state.locations)

    new_player_scenes = Map.put(state.player_scenes, scene, name)
    show_new_player(new_player_scenes, name, location)

    {
      :reply,
      name,
      %__MODULE__{
        state |
        next_player: state.next_player + 1,
        player_scenes: new_player_scenes,
        locations: Map.put(state.locations, scene, location)
      }
    }
  end

  def handle_cast({:move, scene, direction}, state) do
    new_locations =
      case move(scene, direction, state.size, state.locations) do
        {:ok, location} ->
          show_player_move(
            state.player_scenes,
            Map.fetch!(state.player_scenes, scene),
            location
          )
          Map.put(state.locations, scene, location)
        :rejected ->
          state.locations
      end
    {:noreply, %__MODULE__{state | locations: new_locations}}
  end

  defp starting_location({width, height} = size, locations) do
    new_location = {:rand.uniform(width) - 1, :rand.uniform(height) - 1}
    if new_location in Map.values(locations) do
      starting_location(size, locations)
    else
      new_location
    end
  end

  defp move(scene, direction, size, locations) do
    case Grid.move(Map.fetch!(locations, scene), direction, size) do
      {:ok, location} ->
        if location not in Map.values(locations) do
          {:ok, location}
        else
          :rejected
        end
      :out_of_bounds ->
        :rejected
    end
  end

  defp show_new_player(scenes, name, location) do
    send_to_all(scenes, fn scene ->
      Home.show_new_player(scene, name, location)
    end)
  end

  defp show_player_move(scenes, name, location) do
    send_to_all(scenes, fn scene ->
      Home.show_player_move(scene, name, location)
    end)
  end

  defp send_to_all(scenes, message) do
    scenes
    |> Map.keys
    |> Enum.each(message)
  end
end
