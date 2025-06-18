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
  # support both {{ t.key.subkey }} and {{ t[key.subkey] }}
  content.gsub(/\{\{\s*t(?:\.|\[)([^\}\]]+)\s*\}\}/) do
    key_path = $1.strip.gsub(/['"]/, '') # clean up quotes in bracket notation
    keys = key_path.split('.')
    value = keys.reduce(translations) do |acc, key|
      acc.is_a?(Hash) && acc[key] ? acc[key] : nil
    end
    value || "{{ missing t.#{key_path} }}"
  end
end

def resolve_includes(content)
  content.gsub(/\{\%\s*include\s*['"]([^'"]+)['"]\s*(?:with\s+([^\%\}]+))?\s*\%\}/) do
    file = $1.strip
    param = $2&.strip

    include_path = File.join(BLOCKS_DIR, file)
    included_content = File.read(include_path)

    if param
      "{% assign include = #{param} %}\n" + included_content
    else
      included_content
    end
  end
end


def compile_template(template_path, layout_path, translations, email_type)
  content = File.read(template_path)
  content = resolve_includes(content)
  content = interpolate_translations(content, translations)

  layout = File.read(layout_path)

  layout = resolve_includes(layout)
  layout = layout.gsub('{{ content }}', content)
  preview_key = "#{email_type}.iftext"
  layout = layout.gsub('{{ t[preview_text_key] }}', "{{ t.#{preview_key} }}")
  layout = layout.gsub('{{ email_type }}', "#{email_type}")


  layout = interpolate_translations(layout, translations)

  layout
end

Dir.glob("#{SOURCE_DIR}/**/*.liquid") do |template_path|
  filename = File.basename(template_path, '.liquid')
  email_type = File.basename(File.dirname(template_path))
  lang = filename # ex: "en"
  output_filename = "#{email_type}_#{lang}.html"
  output_path = File.join(OUTPUT_DIR, output_filename)
  layout_filename = if email_type.include?("loop")
    "layout_loops_#{lang}.liquid"
  else
    "layout_#{lang}.liquid"
  end

  layout_path = File.join(BLOCKS_DIR, layout_filename)
  translations = load_translations(lang)

  html = compile_template(template_path, layout_path, translations, email_type)
  FileUtils.mkdir_p(OUTPUT_DIR)
  File.write(output_path, html)
  puts "✅ Compiled #{output_filename}"
end
