require 'fileutils'
require 'yaml'

SOURCE_DIR = 'templates'
BLOCKS_DIR = 'blocks'
OUTPUT_DIR = 'output'
LOCALES_DIR = 'locales'

def load_translations(lang)
  file = File.join(LOCALES_DIR, "#{lang}.yml")
  YAML.load_file(file)
end

def interpolate_translations(content, translations)
  content.gsub(/\{\{\s*t\.([^\}]+)\s*\}\}/) do
    keys = $1.strip.split('.')
    value = keys.reduce(translations) do |acc, key|
      acc.is_a?(Hash) && acc[key] ? acc[key] : nil
    end

    value || "{{ missing t.#{$1} }}"
  end
end


def resolve_includes(content)
  content.gsub(/\{\%\s*include\s*['"]([^'"]+)['"]\s*\%\}/) do
    include_path = File.join(BLOCKS_DIR, $1)
    File.read(include_path)
  end
end

def compile_template(template_path, layout_path, translations)
  content = File.read(template_path)
  content = resolve_includes(content)
  content = interpolate_translations(content, translations)

  layout = File.read(layout_path)
  layout = resolve_includes(layout)
  layout = layout.gsub('{{ content }}', content)
  layout = interpolate_translations(layout, translations)

  layout
end

Dir.glob("#{SOURCE_DIR}/**/*.liquid") do |template_path|
  filename = File.basename(template_path, '.liquid')
  email_type = File.basename(File.dirname(template_path))
  lang = filename # ex: "en"
  output_filename = "#{email_type}_#{lang}.html"
  output_path = File.join(OUTPUT_DIR, output_filename)

  layout_path = File.join(BLOCKS_DIR, "layout_#{lang}.liquid")
  translations = load_translations(lang)

  html = compile_template(template_path, layout_path, translations)
  FileUtils.mkdir_p(OUTPUT_DIR)
  File.write(output_path, html)
  puts "✅ Compiled #{output_filename}"
end
