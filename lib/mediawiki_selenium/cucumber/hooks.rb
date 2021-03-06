Before('@custom-browser') do |scenario|
  @scenario = scenario
end

AfterConfiguration do |config|
  MediawikiSelenium::Environment.default_test_directory = config.paths.first || '.'

  # Install a formatter that can be used to show feature-related warnings
  pretty_format, io = config.formats.find { |(format, _io)| format == 'pretty' }
  config.formats << ['MediawikiSelenium::WarningsFormatter', io] if pretty_format
end

# Determine scenario name and setup the environment
Before do |scenario|
  @scenario_name =
    if scenario.respond_to? :feature
      "#{scenario.feature.title}: #{scenario.title}"
    elsif scenario.respond_to? :scenario_outline
      outline = scenario.scenario_outline
      "#{outline.feature.title}: #{outline.title}: #{scenario.name}"
    else
      scenario.name
    end

  setup(name: @scenario_name)
end

# Enforce a dependency check for all scenarios tagged with @extension- tags
Before do |scenario|
  # Backgrounds themselves don't have tags, so get them from the feature
  if scenario.is_a?(Cucumber::Ast::Background)
    tag_source = scenario.feature
  else
    tag_source = scenario
  end

  tags = tag_source.source_tag_names
  dependencies = tags.map { |tag| tag.match(/^@extension-(.+)$/) { |m| m[1].downcase } }.compact
  missing = missing_extensions(dependencies)

  if missing.any?
    scenario.skip_invoke!

    if scenario.feature.respond_to?(:mw_warn)
      warning = "Skipped feature due to missing MediaWiki extensions: #{missing.join(", ")}"
      scenario.feature.mw_warn(warning, 'missing MediaWiki extensions')
    end
  end
end

Before do
  # Create a unique random string for this scenario
  @random_string = Random.new.rand.to_s
end

After do |scenario|
  artifacts =
    if scenario.respond_to?(:status)
      teardown(name: @scenario_name, status: scenario.status)
    else
      teardown(name: @scenario_name)
    end

  artifacts.each { |path, mime_type| embed(path, mime_type) }
end
