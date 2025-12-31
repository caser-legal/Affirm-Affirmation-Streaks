# Affirm Website

This folder contains the website for the Affirm iOS app, including Privacy Policy, Terms of Service, and Support pages.

## 🚀 Quick Deploy to GitHub Pages

### Option 1: Deploy from this repository

1. **Enable GitHub Pages:**
   - Go to your repository on GitHub
   - Click Settings > Pages
   - Under "Source", select "Deploy from a branch"
   - Select branch: `main` (or `master`)
   - Select folder: `/docs`
   - Click Save

2. **Access your site:**
   - Your site will be available at: `https://yourusername.github.io/Affirm/`
   - Wait 2-3 minutes for initial deployment

### Option 2: Create separate website repository

1. **Create new repository:**
   ```bash
   # Create new repo on GitHub named "affirm-website"
   # Then clone it locally
   git clone https://github.com/yourusername/affirm-website.git
   cd affirm-website
   ```

2. **Copy website files:**
   ```bash
   # Copy all files from docs folder
   cp /path/to/Affirm/docs/* .
   ```

3. **Push to GitHub:**
   ```bash
   git add .
   git commit -m "Initial website"
   git push origin main
   ```

4. **Enable GitHub Pages:**
   - Go to repository Settings > Pages
   - Select branch: `main`
   - Select folder: `/ (root)`
   - Click Save

5. **Access your site:**
   - Your site will be available at: `https://yourusername.github.io/affirm-website/`

## 📝 Update URLs in App Store Connect

Once your website is live, update these URLs in App Store Connect:

- **Privacy Policy URL:** `https://yourusername.github.io/affirm-website/privacy.html`
- **Terms of Service URL:** `https://yourusername.github.io/affirm-website/terms.html`
- **Support URL:** `https://yourusername.github.io/affirm-website/support.html`

## 🎨 Customization

### Update Contact Email

Replace `support@affirmapp.com` with your actual email in:
- `privacy.html` (line 186)
- `terms.html` (line 186)
- `support.html` (line 186)

### Update Website URL

Replace `https://affirmapp.com` with your actual URL in:
- `privacy.html` (line 187)
- `terms.html` (line 187)

### Update App Store Link

Once your app is approved, update the "Download on App Store" link in:
- `index.html` (line 86)

Replace `#` with your actual App Store URL:
```html
<a href="https://apps.apple.com/app/idYOUR_APP_ID" class="btn">Download on App Store</a>
```

## 📄 Files Included

- `index.html` - Main landing page
- `privacy.html` - Privacy Policy
- `terms.html` - Terms of Service
- `support.html` - Support & FAQ
- `README.md` - This file

## 🔧 Local Testing

To test the website locally:

```bash
# Navigate to docs folder
cd docs

# Start a simple HTTP server (Python 3)
python3 -m http.server 8000

# Or use Python 2
python -m SimpleHTTPServer 8000

# Open browser to http://localhost:8000
```

## ✅ Checklist

Before submitting to App Store:

- [ ] Deploy website to GitHub Pages
- [ ] Verify all pages load correctly
- [ ] Update contact email in all pages
- [ ] Update website URL in all pages
- [ ] Test all internal links work
- [ ] Copy Privacy Policy URL for App Store Connect
- [ ] Copy Terms of Service URL for App Store Connect
- [ ] Copy Support URL for App Store Connect

## 🌐 Alternative Hosting Options

If you prefer not to use GitHub Pages:

- **Netlify:** Free, automatic HTTPS, custom domain support
- **Vercel:** Free, fast deployment, custom domain support
- **Firebase Hosting:** Free tier available, Google infrastructure
- **Cloudflare Pages:** Free, fast, custom domain support

All of these services can deploy directly from a GitHub repository.

## 📧 Support

If you need help deploying the website, contact:
- GitHub Pages Documentation: https://docs.github.com/pages
- Netlify Documentation: https://docs.netlify.com
- Vercel Documentation: https://vercel.com/docs
