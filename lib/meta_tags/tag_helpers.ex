defmodule PhoenixMetaTags.TagHelpers do
  use Phoenix.HTML
  alias PhoenixMetaTags.MapHelper
  @config_read Application.get_all_env(:phoenix_meta_tags)

  @default_tags ["title", "description", "image", "url"]

  defp config do
    @config_read
    |> Enum.into(%{})
    |> MapHelper.flatMap()
  end

  defp config(key) do
    Map.get(config(), key)
  end

  defp is_default_tag(t) do
    Enum.member?(@default_tags, t) == true
  end

  defp get_value(tags, item) do
    tags[item] || config(item)
  end

  # will return exac value if key is override the default key
  # ex: `og:title` will override `title` when render og
  defp get_tags_value(tags, default_key, key) do
    tags[key] || tags[default_key] || config(default_key)
  end

  @doc """
    Render default meta tags
  """
  @spec render_tag_default(Map.t() | nil) :: Keyword.t() | List.t()
  def render_tag_default(nil), do: []

  def render_tag_default(tags) do
    [
      content_tag(:title, get_value(tags, "title")),
      tag(:meta, content: get_value(tags, "title"), name: "title"),
      tag(:meta, content: get_value(tags, "description"), name: "description")
    ]
  end

  @doc """
    Render meta tags for open graph
  """
  @spec render_tag_og(Map.t() | nil) :: Keyword.t() | List.t()
  def render_tag_og(nil), do: []

  def render_tag_og(tags) do
    [
      tag(:meta, content: "website", property: "og:type"),
      tag(:meta, content: get_tags_value(tags, "url", "og:url"), property: "og:url"),
      tag(:meta, content: get_tags_value(tags, "title", "og:title"), property: "og:title"),
      tag(:meta,
        content: get_tags_value(tags, "description", "og:description"),
        property: "og:description"
      ),
      tag(:meta, content: get_tags_value(tags, "image", "og:image"), property: "og:image")
    ]
  end

  @doc """
    Render meta tags for twitter
  """
  @spec render_tag_twitter(Map.t() | nil) :: Keyword.t() | List.t()
  def render_tag_twitter(nil), do: []

  def render_tag_twitter(tags) do
    [
      tag(:meta, content: "summary_large_image", property: "twitter:card"),
      tag(:meta, content: get_tags_value(tags, "url", "twitter:url"), property: "twitter:url"),
      tag(:meta,
        content: get_tags_value(tags, "title", "twitter:title"),
        property: "twitter:title"
      ),
      tag(:meta,
        content: get_tags_value(tags, "description", "twitter:description"),
        property: "twitter:description"
      ),
      tag(:meta,
        content: get_tags_value(tags, "image", "twitter:image"),
        property: "twitter:image"
      )
    ]
  end

  @spec render_tags_other(Map.t() | nil) :: Keyword.t()
  def render_tags_other(nil), do: []

  def render_tags_other(tags) do
    tags
    |> MapHelper.flatMap()
    |> Map.drop(@default_tags)
    |> render_tags_map()
  end

  def render_tags_map(map) do
    map
    |> Enum.map(fn {k, v} ->
      tag(:meta, content: v, property: k)
    end)
  end

  @doc """
    Render all meta tags for default, open graph and twitter
  """
  @spec render_tags_all(Map.t() | nil) :: Keyword.t() | List.t()
  def render_tags_all(nil), do: []

  def render_tags_all(tags) do
    ntags = MapHelper.flatMap(tags)
    new_tags = Map.merge(config(), ntags)

    other_tags = Map.drop(new_tags, @default_tags)

    Enum.reduce(
      [
        :render_tag_default,
        :render_tag_og,
        :render_tag_twitter
      ],
      [],
      fn func, acc ->
        acc ++ apply(__MODULE__, func, [new_tags])
      end
    ) ++ render_tags_map(other_tags)
  end
end
