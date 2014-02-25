MRuby.each_target do
  module MRuby
    class Build
      alias_method :old_print_build_summary_for_dll, :print_build_summary
      def print_build_summary 
        old_print_build_summary_for_dll

        ext = (`uname` =~ /darwin/i)? 'dylib' : ENV['OS'] == 'Windows_NT'? 'dll' : 'so'

        mruby_dll = "#{build_dir}/bin/mruby.#{ext}"
        file mruby_dll do |t|
          is_vc = cc.command =~ /^cl(\.exe)?$/
          deffile = "#{File.dirname(__FILE__)}/mruby.def"
          options = {
              :flags => is_vc ? '/DLL' : '-shared',
              :outfile => mruby_dll,
              :objs => '',
              :libs => [
                  (is_vc ? "/DEF:#{deffile}" : ext == 'dylib'? '-Wl,-force_load' : "-Wl,--whole-archive"),
                  libfile("#{build_dir}/lib/libmruby")].flatten.join(" "),
              :flags_before_libraries => '',
              :flags_after_libraries => '',
          }

          _pp "LD", mruby_dll
          sh linker.command + ' ' + (linker.link_options % options)
        end
        Rake::Task.tasks.each do |t|
          if t.name =~ Regexp.new("\\.#{ext}$")
            t.invoke
          end
        end
        puts "================================================"
        puts "           Extras:"
        puts "             #{build_dir}/bin/mruby.#{ext}"
        puts "================================================"
        puts
      end
    end
  end
end
