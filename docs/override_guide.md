# PaperMod Override and Extension Guide

## Overview
This document outlines our approach to customizing the PaperMod theme while maintaining compatibility and upgradability.

## Extension Points

### 1. Template Hierarchy
~~~ text
layouts/
├── _default/          # Base template overrides
│   ├── baseof.html   # Main template structure
│   ├── home.html     # Homepage layout
│   ├── list.html     # Section/list pages
│   └── single.html   # Individual content pages
├── partials/         # Component overrides
│   ├── head.html     # Document head modifications
│   ├── header.html   # Site header/navigation
│   └── footer.html   # Site footer
└── shortcodes/       # Custom content components
~~~

### 2. Asset Pipeline
- **CSS Extensions**: `assets/css/extended/`
  - `custom.css` - Main style overrides
  - `dark-theme.css` - Dark mode specific styles
- **JavaScript**: `assets/js/`
  - Custom scripts loaded through partial overrides
- **Images/Media**: `assets/images/`

## Override Behaviors

### 1. Template Overrides
When overriding PaperMod templates:
- Copy original template from `themes/PaperMod/layouts/`
- Place in corresponding `layouts/` directory
- Maintain block structure and naming
- Document modifications with comments

<!-- Template Override Example -->
~~~ html
{{/* Override: Added custom card layout */}}
{{ define "main" }}
  {{/* Original PaperMod content */}}
  {{ .Content }}
  
  {{/* Custom additions */}}
  {{ partial "cards/project-card.html" . }}
{{ end }}
~~~

### 2. Style Overrides
Approach for CSS modifications:

<!-- Extension Example -->
~~~ css
/* Extend existing PaperMod classes */
.main {
  @apply max-w-none;
}
~~~

<!-- Override Example -->
~~~ css
/* Override PaperMod defaults */
:root {
  --theme: custom-value;
}
~~~

### 3. Functionality Extensions
Methods for adding new features:

<!-- Partial Template Example -->
~~~ html
<!-- layouts/partials/custom-header.html -->
{{ define "custom-header" }}
  <div class="custom-header">
    {{ partial "navigation.html" . }}
    {{ partial "dark-mode-toggle.html" . }}
  </div>
{{ end }}
~~~

<!-- Shortcode Example -->
~~~ html
<!-- layouts/shortcodes/project-card.html -->
<div class="project-card">
  <h3>{{ .Get "title" }}</h3>
  <p>{{ .Get "description" }}</p>
  {{ .Inner }}
</div>
~~~

## Common Patterns

### 1. Dark Mode Integration
~~~ html
<!-- Combining PaperMod and Tailwind dark mode -->
<div class="theme-container {{ if .Site.Params.defaultTheme }}dark{{ end }}">
  <div class="content bg-white dark:bg-gray-900">
    {{ .Content }}
  </div>
</div>
~~~

### 2. Content Cards
~~~ html
<!-- Extending PaperMod's post styling -->
<article class="post-entry {{ with .customClass }}{{ . }}{{ end }}">
  <header class="post-header">
    <h2>{{ .Title }}</h2>
  </header>
  <div class="post-content">
    {{ .Summary }}
  </div>
</article>
~~~

## Maintenance Guidelines

### 1. Version Control
- Document PaperMod version compatibility
- Track override changes in git
- Comment significant modifications

### 2. Testing Checklist
Before implementing overrides:
1. Test with PaperMod's default behavior
2. Verify responsive design
3. Check dark mode functionality
4. Validate accessibility

### 3. Documentation Requirements
For each override:
~~~ markdown
### Override Name
- **Purpose**: Why this override is needed
- **Files**: List of affected files
- **Dependencies**: Any new dependencies
- **Testing**: Specific test cases
- **Notes**: Additional considerations
~~~

## Known Issues and Solutions

### 1. Style Conflicts
Problem:
~~~ css
/* PaperMod default */
.main { max-width: 800px; }

/* Our override */
.main { 
  @apply max-w-none; /* Tailwind override */
}
~~~

Solution:
~~~ css
/* Use more specific selector */
.content-wrapper .main {
  @apply max-w-none;
}
~~~

### 2. JavaScript Integration
Problem:
~~~ html
<!-- Potential script loading conflict -->
<script src="theme-toggle.js"></script>
~~~

Solution:
~~~ html
<!-- Use Hugo's asset pipeline -->
{{ $js := resources.Get "js/theme-toggle.js" | minify }}
<script src="{{ $js.RelPermalink }}" defer></script>
~~~

## Future Considerations

### 1. Upgrade Path
- Keep original PaperMod files unmodified
- Document all customizations
- Use Hugo's override system instead of direct modification

### 2. Performance
- Minimize custom JavaScript
- Optimize asset loading
- Maintain PaperMod's performance benefits

## Resources

### Official Documentation
- [PaperMod Wiki](https://github.com/adityatelange/hugo-PaperMod/wiki)
- [Hugo Template Documentation](https://gohugo.io/templates/)
- [Tailwind CSS Documentation](https://tailwindcss.com/docs)

### Internal References
- Technical Specifications (`docs/technical_specs.md`)
- Style Guide (`docs/style_guide.md`) 