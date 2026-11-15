# JACT Motorcycle Website

Each HTML page contains its own embedded CSS, including page-specific styling. The pages do not depend on an external styles.css file to render their design. Keep all HTML and JavaScript files together in the GitHub Pages repository root.

## Pages
- index.html: home
- about.html: about JACT
- services.html: services
- shop.html: spare parts catalogue
- booking.html: service booking requests
- contact.html: contact
- admin-login.html, admin-dashboard.html, admin-products.html, admin-bookings.html: admin pages (all in the root; no admin folder)

## Setup
Configure the Supabase Project URL and publishable/anon key in config.js. Run schema.sql in Supabase SQL Editor. Never place a service_role or secret key in frontend files.

Note: Remote images and Google Fonts require an internet connection.

## Updated Supabase SQL
Run the complete `schema.sql` in Supabase SQL Editor. It is designed to preserve existing JACT table data and creates the secure `submit_jact_order` function. The matching `shop.js` calls this function so customers can submit an order enquiry without being given permission to read other customers' orders or set their own prices.
