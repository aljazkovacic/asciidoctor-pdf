require 'fileutils'

# NOTE it's necessary to hot patch the installed gem so that RubyGems can find it without Bundler
prawn_spec = Gem::Specification.find_by_name 'prawn'
FileUtils.rm_r prawn_spec.gem_dir, secure: true if Dir.exist? prawn_spec.gem_dir
Process.wait Process.spawn %(git clone --depth=1 https://github.com/prawnpdf/prawn #{File.basename prawn_spec.gem_dir}), chdir: prawn_spec.gems_dir

# Option A: patch dependency versions
#new_prawn_spec_contents = File.read (File.join prawn_spec.gem_dir, 'prawn.gemspec'), mode: 'r:UTF-8'
#ttfunk_version_spec = (%r/'ttfunk', *'(.+?)'/.match new_prawn_spec_contents)[1]
#pdf_core_version_spec = (%r/'pdf-core', *'(.+?)'/.match new_prawn_spec_contents)[1]
#prawn_spec_replacement = prawn_spec
#  .to_ruby
#  .gsub(%r/(ttfunk.+?)"[^"]+"/, %(\\1"#{ttfunk_version_spec}"))
#  .gsub(%r/(pdf-core.+?)"[^"]+"/, %(\\1"#{pdf_core_version_spec}"))

# Option B: regenerate spec file
new_prawn_spec_contents = File.readlines (File.join prawn_spec.gem_dir, 'prawn.gemspec'), mode: 'r:UTF-8'
basedir_line_idx = new_prawn_spec_contents.index {|it| it.start_with? 'basedir =' }
new_prawn_spec_contents[basedir_line_idx] = %(basedir = '#{prawn_spec.gem_dir}'\n)
new_prawn_spec = eval new_prawn_spec_contents.join
new_prawn_spec.version = prawn_spec.version
prawn_spec_replacement = new_prawn_spec.to_ruby

File.write prawn_spec.spec_file, prawn_spec_replacement
