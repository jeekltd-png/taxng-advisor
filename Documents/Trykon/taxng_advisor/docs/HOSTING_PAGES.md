# Host Privacy Policy with GitHub Pages

You can host the in-repo privacy policy for Play Console.

## Steps
1. Push this repository to GitHub.
2. In GitHub: Settings → Pages.
3. Source: `Deploy from a branch`.
4. Branch: `main` (or your default), Folder: `/docs`.
5. Save. Pages will build a site at `https://<your-org>.github.io/<repo>/`.
6. The Privacy Policy is at `https://<your-org>.github.io/<repo>/PRIVACY_POLICY.html`.
   - You may also link the docs index: `https://<your-org>.github.io/<repo>/`.

## Update Store Listing
- Take the generated URL and replace the placeholder in `docs/STORE_LISTING.md`.

## Notes
- GitHub Pages converts Markdown to HTML automatically for files in `/docs`.
- If you use a custom domain, add a `CNAME` file and configure DNS.
