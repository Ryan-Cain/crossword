defmodule CrosswordWeb.CrosswordLive do
  use CrosswordWeb, :live_view

  alias Crossword.Puzzle
  alias Crossword.CrosswordAPI

  def mount(%{"month" => month, "day" => day, "year" => year}, _session, socket) do
    url =
      "https://raw.githubusercontent.com/doshea/nyt_crosswords/master/#{year}/#{month}/#{day}.json"

    puzzle =
      CrosswordAPI.get_puzzle(url)

    clues = Puzzle.combine_questions_and_answers(puzzle)
    initial_grid = Puzzle.get_grid(puzzle)
    # IO.inspect(initial_grid, label: "initial grid")

    formatted_grid = Puzzle.create_rows(initial_grid, puzzle["size"]["cols"])
    # IO.inspect(formatted_grid, label: "formatted grid")
    # IO.inspect(Enum.concat(formatted_grid))

    assigned =
      Puzzle.assign_clue_to_tiles(
        Enum.concat(formatted_grid),
        puzzle["size"]["cols"],
        clues,
        :across,
        0
      )

    reformatted = Puzzle.format_rows(assigned, puzzle["size"]["cols"])
    IO.inspect(reformatted, label: "reformatted")

    {:ok,
     assign(socket,
       grid: reformatted,
       clues_across: puzzle["clues"]["across"],
       clues_down: puzzle["clues"]["down"]
     )}
  end

  def render(assigns) do
    ~H"""
    <div class="flex justify-around w-screen mt-8">
      <div class="bg-light-blue" class="flex flex-col">
        <div :for={row <- @grid} class="flex">
          <div
            :for={tile <- row}
            class={"h-14 w-14 border-black border-2 relative flex justify-center items-center #{tile.style}"}
          >
            <span :if={tile.clue_num > 0} class="absolute top-0 left-0 text-sm">
              <%= tile.clue_num %>
            </span>
            <span :if={tile.letter != "."} class="text-xl">
              <%= tile.letter %>
            </span>
            <span :if={tile.letter == "."} class="bg-black w-full h-full"></span>
          </div>
        </div>
      </div>
      <div class="flex">
        <div>
          <p :for={clue <- @clues_across}><%= clue %></p>
        </div>
        <div>
          <p :for={clue <- @clues_down}><%= clue %></p>
        </div>
      </div>
    </div>
    """
  end
end
