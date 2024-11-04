defmodule Crossword.CrosswordAPI do
  def get_puzzle(url) do
    result = HTTPoison.get!(url)
    Jason.decode!(result.body)
  end
end
