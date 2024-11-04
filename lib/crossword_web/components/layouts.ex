defmodule CrosswordWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is set as the default
  layout on both `use CrosswordWeb, :controller` and
  `use CrosswordWeb, :live_view`.
  """
  use CrosswordWeb, :html

  embed_templates "layouts/*"
end
