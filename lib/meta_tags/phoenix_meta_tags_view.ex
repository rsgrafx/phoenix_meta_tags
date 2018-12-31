defmodule PhoenixMetaTags.TagView do
  use Phoenix.HTML
  alias PhoenixMetaTags.MapHelper

  @moduledoc """
  This module render the tags struct to html meta tag.
  """

  # TODO: merge config with runtime tags map
  # OK: override value if runtime tags has the same key, ex: `og:title` will override `title` when render og

  @config_read Application.get_all_env(:phoenix_meta_tags)
               |> Enum.into(%{})
               |> MapHelper.flatMap()

  defmacro __using__(_) do
    quote do
      alias PhoenixMetaTags.MapHelper
      @default_tags ["title", "description", "image", "url"]
      @config unquote(Macro.escape(@config_read))

      defp is_default_tag(t) do
        Enum.member?(@default_tags, t) == true
      end

      defp get_value(tags, item) do
        tags[item] || @config[item]
      end

      # will return exac value if key is override the default key
      # ex: `og:title` will override `title` when render og
      defp get_tags_value(tags, default_key, key) do
        tags[key] || tags[default_key] || @config[default_key]
      end

      @doc """
        Render default meta tags
      """
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
      def render_tags_all(tags) do
        ntags = MapHelper.flatMap(tags)
        new_tags = Map.merge(@config, ntags)

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
  end
end
