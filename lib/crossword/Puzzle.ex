defmodule Crossword.Puzzle do
  def get_grid(puzzle) do
    Enum.zip(puzzle["grid"], puzzle["gridnums"])
  end

  def create_rows(grid, grid_size) do
    grid_builder =
      Enum.reduce(grid, %{full_grid: [], curr_row: [], counter: 0}, fn tile, grid_build ->
        if grid_build.counter == grid_size do
          grid_build
          |> Map.put(:full_grid, grid_build.full_grid ++ [grid_build.curr_row])
          |> Map.put(:counter, 1)
          |> Map.put(:curr_row, [
            %{letter: elem(tile, 0), clue_num: elem(tile, 1), guess: "", style: ""}
          ])
        else
          grid_build
          |> Map.put(:counter, grid_build.counter + 1)
          |> Map.put(
            :curr_row,
            grid_build.curr_row ++
              [%{letter: elem(tile, 0), clue_num: elem(tile, 1), guess: "", style: ""}]
          )
        end
      end)

    grid_builder =
      if length(grid_builder.curr_row) > 0 do
        Map.put(grid_builder, :full_grid, grid_builder.full_grid ++ [grid_builder.curr_row])
      end

    grid_builder.full_grid
  end

  def format_rows(grid, grid_size) do
    grid_builder =
      Enum.reduce(grid, %{full_grid: [], curr_row: [], counter: 0}, fn tile, grid_build ->
        if grid_build.counter == grid_size do
          grid_build
          |> Map.put(:full_grid, grid_build.full_grid ++ [grid_build.curr_row])
          |> Map.put(:counter, 1)
          |> Map.put(:curr_row, [tile])
        else
          grid_build
          |> Map.put(:counter, grid_build.counter + 1)
          |> Map.put(
            :curr_row,
            grid_build.curr_row ++
              [tile]
          )
        end
      end)

    grid_builder =
      if length(grid_builder.curr_row) > 0 do
        Map.put(grid_builder, :full_grid, grid_builder.full_grid ++ [grid_builder.curr_row])
      end

    grid_builder.full_grid
  end

  def combine_questions_and_answers(puzzle) do
    across_clues_and_answers = Enum.zip(puzzle["clues"]["across"], puzzle["answers"]["across"])
    down_clues_and_answers = Enum.zip(puzzle["clues"]["down"], puzzle["answers"]["down"])

    %{
      across: parse_questions(across_clues_and_answers),
      down: parse_questions(down_clues_and_answers)
    }
  end

  def parse_questions(questions) do
    parsed =
      Enum.reduce(questions, %{}, fn something, question ->
        question_split = String.split(elem(something, 0), ".", parts: 2)

        Map.put(question, List.first(question_split), %{
          answer: elem(something, 1),
          question: elem(something, 0)
        })
      end)

    parsed
  end

  # goes through each element in the grid, and checks if element has a clue num,
  # if it does it
  def assign_clue_to_tiles(grid, grid_col_size, clues, direction, index) do
    increment =
      if direction == :across do
        1
      else
        grid_col_size
      end

    element = Enum.at(grid, index)

    grid =
      if element.clue_num > 0 do
        IO.inspect(element, label: "element at assign clue to tiles")
        across_answer = clues.across[to_string(element.clue_num)].answer
        across_answer_as_list = String.split(across_answer, "", trim: true)
        IO.inspect(across_answer_as_list, label: "across answer as list")
        down_answer = clues.down[to_string(element.clue_num)].answer
        down_answer_as_list = String.split(down_answer, "", trim: true)
        across_clue = clues.across[to_string(element.clue_num)]
        down_clue = clues.down[to_string(element.clue_num)]

        across_grid =
          if not is_nil(across_clue) do
            apply_word(grid, increment, across_answer_as_list, index, across_clue)
          else
            grid
          end

        down_grid =
          if not is_nil(down_clue) do
            apply_word(across_grid || grid, increment, down_answer_as_list, index, down_clue)
          else
            if not is_nil(across_grid) do
              across_grid
            else
              grid
            end

            grid
          end

        down_grid
      else
        grid
      end

    IO.inspect(grid, label: "grid after recursion!!")
    grid
  end

  def apply_word(grid, increment, answer_as_list, index, clue) do
    element = Enum.at(grid, index)
    IO.inspect(element, label: "apply word element")
    IO.inspect(index, label: "apply word index")
    IO.inspect(clue, label: "apply word clues")

    if not is_nil(answer_as_list) and length(answer_as_list) > 0 do
      [_curr_letter | shortened_answer_as_list] = answer_as_list
      IO.inspect(element, label: "apply word, element in if not")

      styles =
        cond do
          length(answer_as_list) == String.length(clue.answer) ->
            "selected-tile-tbl"

          length(answer_as_list) == 1 ->
            "selected-tile-tbr"

          true ->
            "selected-tile-tb"
        end

      new_element = Map.put(element, :style, styles)
      new_grid = List.replace_at(grid, index, new_element)
      apply_word(new_grid, increment, shortened_answer_as_list, index + increment, clue)
    else
      IO.inspect(label: "return grid")
      grid
    end
  end
end
