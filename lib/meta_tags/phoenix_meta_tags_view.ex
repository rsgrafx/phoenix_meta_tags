defmodule PhoenixMetaTags.TagView do
  use Phoenix.HTML

  @moduledoc """
  This module render the tags struct to html meta tag.
  """

  # TODO: merge config with runtime tags map
  # OK: override value if runtime tags has the same key, ex: `og:title` will override `title` when render og

  defmacro __using__(_) do
    quote do
      import PhoenixMetaTags.TagHelpers
    end
  end
end
