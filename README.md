# Merritt Ingest Gem

[![Build Status](https://travis-ci.org/CDLUC3/mrt-ingest-ruby.svg?branch=master)](https://travis-ci.org/CDLUC3/mrt-ingest-ruby)

This microservice is part of the [Merritt Preservation System](https://github.com/CDLUC3/mrt-doc).

## Purpose

This library provides utility methods for preparing content for ingest into Merritt. 

See https://rubygems.org/gems/mrt-ingest

## Used By

This code is used by 
- [Merritt UI](https://github.com/CDLUC3/mrt-dashboard)

## Build instructions

```
$ gem build mrt-ingest.gemspec
$ sudo gem install mrt-ingest-0.0.1.gem
```

## Test instructions

The code below creates a new Merritt object with content consisting of two local files
and one remote URL. The object is submitted to Merritt as a manifest, with the manifest,
local files, and `mrt-erc.txt` made available to Ingest by an
[Mrt::Ingest::OneTimeServer](lib/mrt/ingest/one_time_server.rb)
-- a simple WEBrick-based server that finds itself an open port, serves each file from
a temporary directory, and when all files have been served, shuts down. 

```ruby
require 'mrt/ingest'

client = Mrt::Ingest::Client.new(
  "http://merritt.cdlib.org/object/ingest",
  USERNAME,
  PASSWORD
)
ingest_profile = "demo_merritt_content"
user_agent = "me/My Name"

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

obj.start_ingest(client, ingest_profile, user_agent)
obj.finish_ingest # waits for all files to be served, then shuts down
```

For a more detailed example, see the [Merritt::Atom](https://github.com/CDLUC3/mrt-dashboard/tree/master/lib/merritt/atom)
module of the Merritt dashboard.

## Internal Links
