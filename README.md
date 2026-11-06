# DVC DisTrack Backend Holder

A responsive frontend prototype for your custom backend-management dashboard.

## Included sections
- Overview and projects
- Visual database schema preview (SQL and JSON planning)
- API endpoint catalogue
- File/object storage preview
- User and role preview
- Website connection register
- Activity log preview
- Workspace settings

## Important: current limitations
This is a **frontend prototype only**. It stores demo information in the browser's localStorage. It is not connected to your Cloudflare Worker, D1, R2, or a live authentication service. Do not enter real passwords, customer information, API keys, or other secrets.

## Publish with GitHub Pages
1. Create a GitHub repository named `dvc-distrack-backend-holder`.
2. Upload `index.html`, the `css` folder, and the `js` folder. Keep the folder structure unchanged.
3. In repository Settings, open Pages.
4. Select Deploy from a branch, choose `main` and `/ (root)`, then save.
5. Open the Pages URL GitHub provides.

## Next development stage
Connect the dashboard to your Cloudflare Worker API. Then implement and test D1 table creation, R2 object operations, authentication and server-side activity logs. Keep secrets on the server; never put Cloudflare API tokens or private keys in frontend JavaScript.
