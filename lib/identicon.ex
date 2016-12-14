defmodule Identicon do
    def main(input) do
        input
        |> hash
        |> pick_color
        |> build_grid
        |> shape_grid
        |> create_pixel_map
        |> draw
        |> save(input)
    end

    def save(image, filename) do
        File.write("#{filename}.png", image)
    end

    def draw(%Identicon.Image{pixel_map: map, color: color}) do
        image = :egd.create(250, 250)
        fill = :egd.color(color)

        Enum.each map, fn({start, stop}) -> 
            :egd.filledRectangle(image, start, stop, fill)
        end     

        :egd.render(image)
    end

    def create_pixel_map(%Identicon.Image{grid: grid} = image) do
        pixel_map = Enum.map(grid, fn({_, index}) ->
            horizontal = rem(index, 5) * 50
            vertical = div(index, 5) * 50

            top_left = {horizontal, vertical}
            bottom_right = {horizontal + 50, vertical + 50}

            {top_left, bottom_right}
        end)

        %Identicon.Image{image | pixel_map: pixel_map}
    end

    def build_grid(%Identicon.Image{hex: hex} = image) do
        grid = hex
        |> Enum.chunk(3)
        |> Enum.map(fn([first, second, _] = row) ->
            row ++ [second, first]
        end)
        |> List.flatten
        |> Enum.with_index

        %Identicon.Image{image | grid: grid}
    end

    def shape_grid(%Identicon.Image{grid: grid} = image) do
        shape = Enum.filter(grid, fn({value, _}) -> 
            rem(value, 2) == 0 
        end)

      %Identicon.Image{image | grid: shape}
    end
   
    def mirror_row(row) do
        [first, second, _] = row
        row ++ [second, first]
    end

    def pick_color(image) do
        %Identicon.Image{hex: [r,g,b | _]} = image
        # %Identicon.Image{image | color: [r,g,b]}
        Map.put(image, :color, {r,g,b})
    end

    def hash(input) do
        hex = :crypto.hash(:md5, input)
        |> :binary.bin_to_list
        
        %Identicon.Image{hex: hex}
    end
end
