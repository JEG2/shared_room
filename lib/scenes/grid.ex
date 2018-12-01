defmodule SharedRoom.Grid do
  @pixels_in_cell 20

  def pixels_to_cells({width, height}) do
    {div(width, @pixels_in_cell), div(height, @pixels_in_cell)}
  end

  def cells_to_pixels({width, height}) do
    {width * @pixels_in_cell, height * @pixels_in_cell + @pixels_in_cell}
  end

  def move({x, y}, :left, _size) when x > 0 do
    {:ok, {x - 1, y}}
  end
  def move({x, y}, :right, {width, _height}) when x < width - 1 do
    {:ok, {x + 1, y}}
  end
  def move({x, y}, :up, _size) when y > 0 do
    {:ok, {x, y - 1}}
  end
  def move({x, y}, :down, {_width, height}) when y < height - 1 do
    {:ok, {x, y + 1}}
  end
  def move(_location, _direction, _size), do: :out_of_bounds
end
