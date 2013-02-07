MRuby.each_target do
  module MRuby
    class Build
      alias_method :old_print_build_summary_for_dll, :print_build_summary
      def print_build_summary 
        orig = gems.clone.reject {|g| g.name == 'mruby-dll'}
        old_print_build_summary_for_dll
        gems = orig

        mruby_dll = "#{build_dir}/bin/mruby.dll"
        file mruby_dll do |t|
          is_vc = ENV['OS'] == 'Windows_NT' && cc.command =~ /^cl(\.exe)?$/
          deffile = "#{File.dirname(__FILE__)}/mruby.def"
          options = {
              :flags => is_vc ? '/DLL' : '-shared',
              :outfile => mruby_dll,
              :objs => "",
              :libs => [
                  (is_vc ? '/DEF:' : '') + deffile,
                  libfile("#{build_dir}/lib/libmruby")].flatten.join(" "),
              :flags_before_libraries => '',
              :flags_after_libraries => '',
          }

          _pp "LD", "#{build_dir}/bin/mruby.dll"
          sh linker.command + ' ' + (linker.link_options % options)
        end
        Rake::Task.tasks.each do |t|
          if t.name =~ /\.dll$/
            t.invoke
          end
        end
        puts "================================================"
        puts "           Extras:"
        puts "             #{build_dir}/bin/mruby.dll"
        puts "================================================"
        puts
      end
    end
  end
end
