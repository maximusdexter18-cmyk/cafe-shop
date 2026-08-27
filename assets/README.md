# Amber & Ash — image assets

Drop your photos in this folder (keep these exact filenames so the site picks them up
automatically once deployed). Images are optional — if a file is missing the page just
falls back to a solid colour, nothing breaks.

## Required for the look you asked for

| File                 | Where it's used                                                        |
|----------------------|------------------------------------------------------------------------|
| `doors.jpg`          | Homepage hero — the two halves of the shop door that split apart on scroll. Use one wide photo of the closed shopfront/doors. |
| `interior.jpg`       | Full-page background behind the whole homepage (the interior you see as the doors open). |
| `interior.mp4`       | *Optional.* If present, the interior background plays as a looping video instead of `interior.jpg`. |
| `about.jpg`          | A separate photo used in the dedicated "Inside the café" band on the homepage (not the hero). |
| `menu-paper.jpg`     | The "physical menu" paper texture behind the menu items (homepage preview + the Order page). A warm, paper-ish photo works best. |
| `booking-bg.jpg`     | Background image behind the Book-a-table page (dimmed automatically).   |

## Per-item product photos (optional)

In the **Menu Manager** (`admin.html`, after you sign in), each item has an
"Image URL" field. You can paste either:
- a full `https://…` link (e.g. an uploaded Supabase Storage URL), or
- a relative path like `assets/my-latte.jpg` if you put the file in this folder.

## Pages that use these images
- `index.html` — hero `doors.jpg`, full-page `interior.jpg`, band `about.jpg`.
- `menu.html` — "foldable book" menu: cover (cafe name + design) → category pages; sits on `menu-paper.jpg`.
- `order.html` — menu items on `menu-paper.jpg`; each item can show its own `image_url`.
- `booking.html` — `booking-bg.jpg` behind the form.

All photos are sized with `background-size:cover` / `object-fit:cover`, so they auto-crop
to fill on both phone and desktop — just use reasonably high-res source images.

## Shared footer (`footer.js`)
Drop `import { renderFooter } from './footer.js'; renderFooter();` into any page's module
to append the site footer (links, address, mailto, Instagram/Facebook placeholders
marked `data-social="instagram"` / `data-social="facebook"` for find/replace). Used on
`index.html`, `menu.html`, `order.html`, and `booking.html`.

## Tips
- Landscape photos (3:2 or wider) suit the doors hero and interior best.
- Keep files reasonably small (under ~500 KB each) for fast loading on mobile.
- JPG is fine for photos; use `.jpg`/`.jpeg`/`.png`/`.webp` extensions as named above.
- After adding/changing files, redeploy (or refresh your static server) — the site
  references them by these fixed names.

You do NOT upload the menu *items* here — those are entered as data in the Menu Manager
(or I can bake them into `schema.sql`). Only the *pictures* live in this folder.