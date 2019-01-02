defmodule PhoenixMetaTags.MetaTagPlug do
  @moduledoc """
  Documentation for PhoenixMetaTags.
  """

  import Plug.Conn, only: [assign: 3]

  def init(opts), do: opts

  def call(conn, %{meta_tags: meta}) do
    put_meta_tags(conn, meta)
  end

  def call(conn, _) do
    put_meta_tags(conn, meta_tags())
  end

  def put_meta_tags(conn, tags \\ %{}) do
    meta = meta_tags()
    tags = Map.merge(meta, tags)
    assign(conn, :meta_tags, tags)
  end

  def meta_tags do
    meta = Application.get_all_env(:phoenix_meta_tags)
    Enum.into(meta, %{})
  end

end