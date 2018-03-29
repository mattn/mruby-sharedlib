module MRuby
  class Build
    def mruby_sharedlib_ext
      (`uname` =~ /darwin/i)? 'dylib' : (ENV['OS'] == 'Windows_NT')? 'dll' : 'so'
    end

    def exefile(name)
      if name.is_a?(Array)
        name.flatten.map { |n| exefile(n) }
	  elsif name !~ /\./
        "#{name}#{exts.executable}"
      else
        name
      end
    end
  end
end

MRuby.each_target do
  next if kind_of? MRuby::CrossBuild

  mruby_sharedlib = "#{build_dir}/bin/mruby.#{mruby_sharedlib_ext}"
  @bins << "mruby.#{mruby_sharedlib_ext}"

  is_vc = cc.command =~ /^cl(\.exe)?$/
  unless is_vc
    self.cc.flags << '-fPIC'
    self.cxx.flags << '-fPIC'
  end

  file mruby_sharedlib => libfile("#{build_dir}/lib/libmruby") do |t|
    is_mingw = ENV['OS'] == 'Windows_NT' && cc.command =~ /^gcc/
    deffile = "#{File.dirname(__FILE__)}/mruby.def"
    unsed_whole_archive = false

    gem_flags = gems.map { |g| g.linker.flags }
    if is_vc
      gem_flags << '/DLL' << "/DEF:#{deffile}"
    else
      gem_flags << '-shared'
      gem_flags <<
        if mruby_sharedlib_ext == 'dylib'
          '-Wl,-force_load'
        elsif is_mingw
          deffile
        else
          unsed_whole_archive = true
          "-Wl,--whole-archive"
        end
    end
    gem_flags << "/MACHINE:#{ENV['Platform']}" if is_vc && ENV['Platform']
    gem_flags += t.prerequisites
    gem_flags << '-Wl,--no-whole-archive' if unsed_whole_archive
    gem_libraries = gems.map { |g| g.linker.libraries }
    gem_library_paths = gems.map { |g| g.linker.library_paths }
    gem_flags_before_libraries = gems.map { |g| g.linker.flags_before_libraries }
    gem_flags_after_libraries = gems.map { |g| g.linker.flags_after_libraries }
    linker.run t.name, [], gem_libraries, gem_library_paths, gem_flags, gem_flags_before_libraries, gem_flags_after_libraries
  end
end
