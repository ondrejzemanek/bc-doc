module MiddlemanHelpers

  GITHUB_URL = 'https://github.com'

  # Returns URI of the current page's source file in the GitHub repository for
  # online edit.
  def github_edit_link
    source_file_path = current_page.file_descriptor.relative_path
    repo_slug = config[:site][:github][:repo_slug]
    branch = config[:site][:github][:branch]

    [GITHUB_URL, repo_slug, 'edit', branch, config[:source], source_file_path].join('/')
  end

  # Returns SVG code to use beforehand declared SVG symbol.
  def use_icon(icon_id)
    <<-HTML
      <svg xmlns="http://www.w3.org/2000/svg" class="icon">
        <use xlink:href="#icon-#{icon_id}" />
      </svg>
    HTML
  end

  #### Navigation ####

  def link_to_page(resource)
    link_to(nav_title(resource), resource, {
      class: ('current' if current_resource == resource)
    })
  end

  # Returns title of the page for using in navigation.
  def nav_title(resource)
    resource.data['nav-title'] || resource.data.title
  end

  # Returns children pages of the given page sorted by nav-weight and title.
  def nested_pages(resource)
    resource.children
      .find_all { |r| nav_title(r) }
      .sort_by { |r| [r.data['nav-weight'] || 100, nav_title(r)] }
  end

  # Returns root page (index) of the site.
  def root_page
    sitemap.find_resource_by_path(config.index_file)
  end
end
