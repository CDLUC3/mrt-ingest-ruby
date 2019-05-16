## 0.0.5 (Next)

- Invalid arguments (nil required parameters, string URLs where `URI` objects are expected, etc.) 
  now raise `ArgumentError` instead of `IngestException`.

### Developer notes

- Updates code for Ruby 2.4
- Adds RuboCop style checks
- Replaces Test::Unit with RSpec

## 0.0.4 (2018-10-23)

- Updates `json` gem from `~> 1.5` to `~> 2.0`
- Updates `rest-client` gem from `~> 1.6` to `~> 2.0`

## 0.0.3 (2018-10-23)

- Adds prefetch option for remote URLs
- Ensures one-time server is only started once

## 0.0.2 (2011-12-19)

- First public release