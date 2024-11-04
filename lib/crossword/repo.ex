defmodule Crossword.Repo do
  use Ecto.Repo,
    otp_app: :crossword,
    adapter: Ecto.Adapters.Postgres
end
