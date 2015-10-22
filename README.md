# mruby-sharedlib

Generate shared library of mruby.

## Supported OSs

* Windows (dll)
* Linux (so)
* Mac OSX (dylib)

## Usage

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'mattn/mruby-sharedlib'
end
```

You can find the shared library generated in MRUBY_DIR/build/host/bin/mruby.(so|dll|dylib).

## License

MIT

## Author

Yasuhiro Matsumoto (a.k.a mattn)
