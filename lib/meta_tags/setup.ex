defmodule PhoenixMetaTags.Setup do

  defmacro __using__(_) do
    quote do
      import PhoenixMetaTags.MetaTagPlug
      alias PhoenixMetaTags.MetaTagPlug
    end
  end
end