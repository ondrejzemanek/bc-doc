require_relative 'lib/sass_functions'
require_relative 'lib/middleman_helpers'

helpers MiddlemanHelpers

config[:layouts_dir] = '_layouts'
config[:sass_assets_paths] << Foundation.scss_path

# Custom config variables
config[:site] = {
  github: {
    repo_slug: 'bigclownlabs/bc-doc',
    branch: 'master'
  }
}

activate :asciidoc, attributes: {
  'source-language' => 'sh',
  'source-highlighter' => 'coderay',
  'coderay-css' => 'style',
  'sectanchors' => 'true',
}

# Automatically add width and heigh attributes (detected by fastimage gem) to
# the img tag created with image_tag helper. This does not work for images in
# AsciiDoc documents.
activate :automatic_image_sizes

configure :development do
  Bundler.require(:development)

  # Reload the browser automatically whenever files change.
  activate :livereload, no_swf: true, host: '127.0.0.1'
end

# Build-specific configuration
configure :build do
  activate :minify_css
end
