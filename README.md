# Mara - Website Generator

Avoid repetitive code by generating the HTML files from the Templates. I created this generator to create multi-page AlpineJS based website that can be hosted in Github pages or in any other static site host.

## Install

```
curl -fsSL https://github.com/aravindavk/mara/releases/latest/download/install.sh | sudo bash -x
```

## Development setup/preview

```
mara dev
```

## Build the Site

```
mara build
```

## Site layout

```
$SRC/
  - views/
      - partials/
      - layouts/
      - index.html.j2
      - about.html.j2
      - contact/index.html.j2
  - public/
      - js/
         - alpinejs@3.10.2.js
      - css/
         - stylesheet.css
      - images/
         - logo.png
```

Generated Output directory

```
output/
    - index.html
    - about/
        - index.html
    - contact/
        - index.html
    - js/
       - alpinejs@3.10.2.js
    - css/
       - stylesheet.css
    - images/
       - logo.png
```
