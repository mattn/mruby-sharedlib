# mruby-sharedlib

Generate shared library of mruby.

## Supported OSs

* Windows
* Linux
* Mac OSX

## Usage

```ruby
MRuby::Build.new do |conf|

    # ... (snip) ...

    conf.gem :github => 'mattn/mruby-sharedlib'
end
```

## License

MIT

## Author

Yasuhiro Matsumoto (a.k.a mattn)
