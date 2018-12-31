use Mix.Config

config :phoenix_meta_tags,
  title: "**Base Title for Site**",
  description: "Some base description",
  fb: %{
    appid: "1200129192192192",
    video: %{
      name: "video_name",
      width: "100",
      height: "200",
      specs: %{
        north: "n100",
        west: "w200"
      }
    }
  },
  "fb:video": "abc"
