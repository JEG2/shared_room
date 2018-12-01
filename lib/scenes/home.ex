defmodule SharedRoom.Scene.Home do
  use Scenic.Scene
  alias Scenic.Graph
  alias SharedRoom.{Grid, Room}
  import Scenic.Primitives, only: [text: 3]

  defstruct graph: nil,
            player_icons: ["#", "&"]

  def show_new_player(scene, name, location) do
    GenServer.cast(scene, {:show_new_player, name, location})
  end

  def show_player_move(scene, name, location) do
    GenServer.cast(scene, {:show_player_move, name, location})
  end

  def init(_scene_args, _options) do
    graph =
      Graph.build(clear_color: :white, fill: :black, font_size: 20)
      |> push_graph

    Room.register_scene(self())

    {:ok, %__MODULE__{graph: graph}}
  end

  def handle_cast({:show_new_player, name, location}, state) do
    [player_icon | icons] = state.player_icons
    new_graph =
      state.graph
      |> text(player_icon, translate: Grid.cells_to_pixels(location), id: name)
      |> push_graph
    {:noreply, %__MODULE__{state | graph: new_graph, player_icons: icons}}
  end
  def handle_cast({:show_player_move, name, location}, state) do
    new_graph =
      state.graph
      |> Graph.modify(
        name,
        &text(&1, &1.data, translate: Grid.cells_to_pixels(location))
      )
      |> push_graph
    {:noreply, %__MODULE__{state | graph: new_graph}}
  end

  def handle_input({:codepoint, {"w", 0}}, _context, state) do
    move(:up)
    {:noreply, state}
  end
  def handle_input({:codepoint, {"a", 0}}, _context, state) do
    move(:left)
    {:noreply, state}
  end
  def handle_input({:codepoint, {"s", 0}}, _context, state) do
    move(:down)
    {:noreply, state}
  end
  def handle_input({:codepoint, {"d", 0}}, _context, state) do
    move(:right)
    {:noreply, state}
  end
  def handle_input(_input, _context, state), do: {:noreply, state}

  defp move(direction) do
    Room.move(self(), direction)
  end
end
