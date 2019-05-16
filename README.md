# mrt-ingest (ruby)

## What?

A Ruby ingest client for [Merritt](https://merritt.cdlib.org/).

## Install

```
$ gem build mrt-ingest.gemspec
$ sudo gem install mrt-ingest-0.0.1.gem
```

## Usage

```ruby
require 'mrt/ingest'

client = Mrt::Ingest::Client.new(
  "http://merritt.cdlib.org/object/ingest",
  USERNAME,
  PASSWORD
)

obj = Mrt::Ingest::IObject.new(
  erc: {
    "who" => "Doe, John",
    "what" => "Hello, world",
    "when/created" => "2011"
  }
)
obj.add_component(File.new("/tmp/helloworld_a"))
obj.add_component(File.new("/tmp/helloworld_b"))
obj.add_component(
  URI.parse("http://example.org/xxx"),
  name: "helloworld_c",
  digest: Mrt::Ingest::MessageDigest::MD5.new("6f5902ac237024bdd0c176cb93063dc4")
)

obj.start_ingest(client, "demo_merritt_content", "me/My Name")
obj.finish_ingest
```
