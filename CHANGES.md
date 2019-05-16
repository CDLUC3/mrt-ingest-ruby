## 0.0.5 (Next)

- Updates code for Ruby 2.4+; adds style checks
- Invalid arguments (nil required parameters, string URLs where `URI` objects are expected, etc.) 
  now raise `ArgumentError` instead of `IngestException`.
