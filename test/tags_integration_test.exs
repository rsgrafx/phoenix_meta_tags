defmodule MetaTagIntegrationTests do
  use ExUnit.Case, async: true

  use PhoenixMetaTags.Setup

  describe "Using functionality as plug" do
    setup do
      tags = %{
        meta_tags: %{title: "**Base Title for Site**", description: "Some base description"}
      }

      {:ok, %{conn: Plug.Test.conn(:get, "/"), meta: tags}}
    end

    test "maintains meta_tags assignment variable", %{conn: conn, meta: meta} do
      conn = MetaTagPlug.call(conn, meta)
      assert %{meta_tags: %{title: "**Base Title for Site**"}} = conn.assigns
    end

    test "Internal overrides still work as normal", %{conn: conn} do
      tags = %{
        meta_tags: %{
          title: "Foo Bar Dog",
          description: "Description set within a controller"
        }
      }

      assert %{
               meta_tags: %{
                 title: "Foo Bar Dog",
                 description: "Description set within a controller",
                 fb: %{
                   appid: "1200129192192192"
                 }
               }
             } = MetaTagPlug.call(conn, tags).assigns
    end
  end
end
