module MRuby
  class Build
    def mruby_dll_ext
      (`uname` =~ /darwin/i)? 'dylib' : (ENV['OS'] == 'Windows_NT')? 'dll' : 'so'
    end
  end
end

MRuby.each_target do
  next if kind_of? MRuby::CrossBuild

  alias default_exefile exefile

  def self.exefile(name)
    return name if name.kind_of? String and name.end_with? ".#{mruby_dll_ext}"
    default_exefile name
  end

  mruby_dll = "#{build_dir}/bin/mruby.#{mruby_dll_ext}"
  @bins << "mruby.#{mruby_dll_ext}"

  file mruby_dll => libfile("#{build_dir}/lib/libmruby") do |t|
    is_vc = cc.command =~ /^cl(\.exe)?$/
    deffile = "#{File.dirname(__FILE__)}/mruby.def"

    gem_flags = gems.map { |g| g.linker.flags }
    gem_flags << (is_vc ? "/DEF:#{deffile}" : mruby_dll_ext == 'dylib'? '-Wl,-force_load' : "-Wl,--whole-archive")
    gem_flags += t.prerequisites
    gem_libraries = gems.map { |g| g.linker.libraries }
    gem_library_paths = gems.map { |g| g.linker.library_paths }
    gem_flags_before_libraries = gems.map { |g| g.linker.flags_before_libraries } + [is_vc ? '/DLL' : '-shared']
    gem_flags_after_libraries = gems.map { |g| g.linker.flags_after_libraries }
    linker.run t.name, [], gem_libraries, gem_library_paths, gem_flags, gem_flags_before_libraries, gem_flags_after_libraries
  end
end
