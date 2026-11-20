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

SVG diagrams should carry their own `prefers-color-scheme: dark` styles so they follow the site's light/dark mode.
For SVGs that don't, `scripts/svg-darkmode.ps1 <images-dir>` adds a minimal dark block (text and lines only).
PNG diagrams cannot adapt and are shown on a white card.

## Local preview

Needs [Hugo Extended](https://gohugo.io/installation/) (the site is built with 0.170.1).

```
hugo server
```

## Deploying

Pushing to `main` builds and publishes the site through `.github/workflows/deploy.yml`.
In the repository settings, Pages must use **GitHub Actions** as its source.
