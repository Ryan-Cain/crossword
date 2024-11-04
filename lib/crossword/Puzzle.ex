defmodule Crossword.Puzzle do

  def get_grid(puzzle) do
    Enum.zip(puzzle["grid"], puzzle["gridnums"])
  end

  def create_rows(grid) do
    grid_builder =
      Enum.reduce(grid, %{full_grid: [], curr_row: [], counter: 0}, fn tile, grid_build ->
        case grid_build.counter do
          15 ->
            grid_build
            |> Map.put(:full_grid, grid_build.full_grid ++ [grid_build.curr_row])
            |> Map.put(:counter, 1)
            |> Map.put(:curr_row, [%{letter: elem(tile, 0), clue_num: elem(tile, 1), guess: ""}])

          x when x <= 14 ->
            grid_build
            |> Map.put(:counter, grid_build.counter + 1)
            |> Map.put(
              :curr_row,
              grid_build.curr_row ++
                [%{letter: elem(tile, 0), clue_num: elem(tile, 1), guess: ""}]
            )
        end
      end)

    grid_builder =
      if length(grid_builder.curr_row) > 0 do
        Map.put(grid_builder, :full_grid, grid_builder.full_grid ++ [grid_builder.curr_row])
      end

    grid_builder.full_grid
  end

  def parse_questions(questions) do
    parsed =
      Enum.reduce(questions, [], fn something, question ->
        question_split = String.split(elem(something, 1), ".", parts: 2)

        [
          {List.first(question_split),
           {elem(something, 0), String.trim(List.last(question_split))}}
          | question
        ]
      end)

    Enum.reverse(parsed)
  end
end
