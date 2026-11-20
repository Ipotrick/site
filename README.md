# Ipotricks Pretty Pixels

Graphics programming blog, built with [Hugo](https://gohugo.io/) and hosted on GitHub Pages.

**Live site: https://ipotrick.github.io/site/**

## Writing a post

```
hugo new content blogs/<slug>
```

This creates a folder with an `index.md` and an `images/` subfolder:

```
content/blogs/<slug>/
  index.md
  images/
```

Reference images relatively, e.g. `![alt](images/diagram.svg)`. Set `draft = false` in the front matter to publish.
Posts are grouped by year and month on the blog overview, and get a table of contents from their headings.

## Diagrams

Diagrams are SVGs in the post's `images/` folder, referenced like normal images: `![alt](images/01.svg)`.
They are inlined into the page at build time (`layouts/_markup/render-image.html`), and the embedded `<style>`
block in each file is dropped. The palette they use (`var(--chart-*)`, `var(--text-*)`, light and dark) is defined
once in `assets/css/diagram.css`, with text and grid colours tied to the site's own tokens in `assets/css/site.css`.
SVGs should use those variables instead of hard-coded colours.

Code highlighting is a hand-written Ayu theme in `assets/css/syntax.css` (Ayu Light / Ayu Dark).
## Local preview

Needs [Hugo Extended](https://gohugo.io/installation/) (the site is built with 0.170.1).

```
hugo server
```

## Deploying

Pushing to `main` builds and publishes the site through `.github/workflows/deploy.yml`.
In the repository settings, Pages must use **GitHub Actions** as its source.
