# Changelog

## Changes 4/18/2025

### fileListView.js

- Seed and persist `itemsPerPage` from `localStorage`
- Use `window.itemsPerPage` for pagination in gallery
- Enable search input filtering in gallery mode
- Always re‑render the view‑toggle button on gallery load
- Restore per‑card action buttons (download, edit, rename, share)
- Assign real `value` to checkboxes and call `updateFileActionButtons()` on change
- Update `changePage` and `changeItemsPerPage` to respect `viewMode`

### fileTags.js

- Import `renderFileTable` and `renderGalleryView`
- Re‑render the list after saving a single‑file tag
- Re‑render the list after saving multi‑file tags

---

## Changes 4/17/2025

- Generate OpenAPI spec and API HTML docs
  - Fully auto‑generated OpenAPI spec (`openapi.json`) and interactive HTML docs (`api.html`) powered by Redoc.
- .gitattributes added to mark (`openapi.json`) & (`api.html`) as documentation.
- User Panel added API Docs link.
- Adjusted remember_me_token.
- Test pipeline

---

## Changes 4/16 Refactor API endpoints and modularize controllers and models

- Reorganized project structure to separate API logic into dedicated controllers and models:
  - Created adminController, userController, fileController, folderController, uploadController, and authController.
  - Created corresponding models (AdminModel, UserModel, FileModel, FolderModel, UploadModel, AuthModel) for business logic.

- Consolidated API endpoints under the /public/api folder with subfolders for admin, auth, file, folder, and upload endpoints.

- Added inline OpenAPI annotations to document key endpoints (e.g., getConfig.php, updateConfig.php) for improved API documentation.

- Updated configuration retrieval and update logic in AdminModel and AdminController to handle OIDC and login option booleans consistently, fixing issues with basic auth settings not updating on the login page.

- Updated the client-side auth.js to correctly reference API endpoints (adjusted query selectors to reflect new document root) and load admin configuration from the updated API endpoints.

- Minor improvements to CSRF token handling, error logging, and overall code readability.

This refactor improves maintainability, testability, and documentation clarity across all API endpoints.

### Refactor fixes and adjustments

- Added fallback checks for disableFormLogin / disableBasicAuth / disableOIDCLogin when coming in either at the top level or under loginOptions.
- Updated auth.js to read and store the nested loginOptions booleans correctly in localStorage, then show/hide the Basic‑Auth and OIDC buttons as configured.
- Changed the logout controller to header("Location: /index.html?logout=1") so after /api/auth/logout.php it lands on the root index.html, not under /api/auth/.
- Switched your share modal code to use a leading slash ("/api/file/share.php") so it generates absolute URLs instead of relative /share.php.
- In the shared‑folder gallery, adjusted the client‑side image path to point at /uploads/... instead of /api/folder/uploads/...
- Updated both AdminModel defaults and the AuthController to use the exact full path
- Network Utilities Overhaul swapped out the old fetch wrapper for one that always reads the raw response, tries to JSON.parse it, and then either returns the parsed object on ok or throws it on error.
- Adjusted your submitLogin .catch() to grab the thrown object (or string) and pass that through to showToast, so now “Invalid credentials” actually shows up.
- Pulled the common session‑setup and “remember me” logic into two new helpers, finalizeLogin() (for AJAX/form/basic/TOTP) and finishBrowserLogin() (for OIDC redirects). That removed tons of duplication and ensures every path calls the same permission‑loading code.
- Ensured that after you POST just a totp_code, we pick up pending_login_user/pending_login_secret, verify it, then immediately call finalizeLogin().
- Expanded checkAuth.php Response now returns all three flags—folderOnly, readOnly, and disableUpload so client can handle every permission.
- In auth.js’s updateAuthenticatedUI(), write all three flags into localStorage whenever you land on the app (OIDC, basic or form). That guarantees consistent behavior across page loads.
- Made sure the OIDC handler reads the live config via AdminModel::getConfig() and pushes you through the TOTP flow if needed, then back to /index.html.
- Dockerfile, custom-php.ini & start.sh moved into main repo for easier onboarding.
- filerise-docker changed to dedicated CI/CD pipeline

---

## Changes 4/15/2025

- Adjust Gallery View max columns based on screen size
- Adjust headerTitle to update globally

## Changes 4/14/2025

- Fix Gallery View: medium screen devices get 3 max columns and small screen devices 2 max columns.
- Ensure gallery view toggle button displays after refresh page.
- Force resumable chunk size & fix chunk cleanup

### filePreview.js Enhancements

**Modal Layout Overhaul:**

- **Left Panel:** Holds zoom in/out controls at the top and the "prev" button at the bottom.
- **Center Panel:** Always centers the preview image.
- **Right Panel:** Contains rotate left/right controls at the top and the "next" button at the bottom.

**Consistent Control Presence:**

- Both left and right panels are always included. When there’s only one image, placeholders are inserted in place of missing navigation buttons to ensure the image remains centered and that rotate controls are always visible.

**Improved Transform Behavior:**

- Transformation values (scale and rotation) are reset on each navigation event, ensuring predictable behavior and consistent presentation.

---

## Changes 4/13/2025 v1.1.3

- Decreased header height some more and clickable logo.
- authModals.js fully updated with i18n.js keys.
- main.js added Dark & Light mode i18n.js keys.
- New Admin section Header Settings to change Header Title.
- Admin Panel confirm unsaved changes.
- Added translations and data attributes for almost all user-facing text
- Extend i18n support: Add new translation keys for Download and Share modals

- **Slider Integration:**
  - Added a slider UI (range input, label, and value display) directly above the gallery grid.
  - The slider allows users to adjust the number of columns in the gallery from 1 to 6.
- **Dynamic Grid Updates:**
  - The gallery grid’s CSS is updated in real time via the slider’s value by setting the grid-template-columns property.
  - As the slider value changes, the layout instantly reflects the new column count.
- **Dynamic Image Resizing:**
  - Introduced a helper function (getMaxImageHeight) that calculates the maximum image height based on the current column count.
  - The max height of each image is updated immediately when the slider is adjusted to create a more dynamic display.
- **Image Caching:**
  - Implemented an image caching mechanism using a global window.imageCache object.
  - Images are cached on load (via an onload event) to prevent unnecessary reloading, improving performance.
- **Event Handling:**
  - The slider’s event listener is set up to update both the gallery grid layout and the dimensions of the thumbnails dynamically.
  - Share button event listeners remain attached for proper functionality across the updated gallery view.

- **Input Validation & Security:**
  - Used `filter_input()` to sanitize and validate incoming GET parameters (token, pass, page).
  - Validated file system paths using `realpath()` and ensured the shared folder lies within `UPLOAD_DIR`.
  - Escaped all dynamic outputs with `htmlspecialchars()` to prevent XSS.
- **Share Link Verification:**
  - Loaded and validated share records from the JSON file.
  - Handled expiration and password protection (with proper HTTP status codes for errors).
- **Pagination:**
  - Implemented pagination by slicing the full file list into a limited number of files per page (default of 10).
  - Calculated total pages and current page to create navigation links.
- **View Toggle (List vs. Gallery):**
  - Added a toggle button that switches between a traditional list view and a gallery view.
  - Maintained two separate view containers (`#listViewContainer` and `#galleryViewContainer`) to support this switching.
- **Gallery View with Image Caching:**
  - For the gallery view, implemented a JavaScript function that creates a grid of image thumbnails.
  - Each image uses a cache-busting query string on first load and caches its URL in a global `window.imageCache` for subsequent renders.
- **Persistent Pagination Controls:**
  - Moved the pagination controls outside the individual view containers so that they remain visible regardless of the selected view.

---

## Changes 4/12/2025

- Moved Gallery view toggle button into header.
- Removed css entries that are not needed anymore for Gallery View Toggle.
- Change search box text when enabling advanced search.
- Advanced/Basic search button as material icon on same row as search bar.

### Advanced Search Implementation

- **Advanced Search Toggle:**
  - Added a global toggle (`window.advancedSearchEnabled`) and a UI button to switch between basic and advanced search modes.
  - The toggle button label changes between "Advanced Search" and "Basic Search" to reflect the active mode.

- **Fuse.js Integration Updates:**
  - Modified the `searchFiles()` function to conditionally include the `"content"` key in the Fuse.js keys only when advanced search mode is enabled.
  - Adjusted Fuse.js options by adding `ignoreLocation: true`, adjusting the `threshold`, and optionally assigning weights (e.g., a lower weight for `name` and a higher weight for `content`) to prioritize matches in file content.

- **Backend (PHP) Enhancements:**
  - Updated **getFileList.php** to read the content of text-based files (e.g., `.txt`, `.html`, `.md`, etc.) using `file_get_contents()`.
  - Added a `"content"` property to the JSON response for eligible files to allow for full-text search in advanced mode.

### Fuse.js Integration for Indexed Real-Time Searching**

- **Added Fuse.js Library:** Included Fuse.js via a CDN `<script>` tag to leverage its client‑side fuzzy search capabilities.
- **Created searchFiles Helper Function:** Introduced a new function that uses Fuse.js to build an index and perform fuzzy searches over file properties (file name, uploader, and nested tag names).
- **Transformed JSON Object to Array:** Updated the loadFileList() function to convert the returned file data into an array (if it isn’t already) and assign file names from JSON keys.
- **Updated Rendering Functions:** Modified both renderFileTable() and renderGalleryView() to use the searchFiles() helper instead of a simple in‑array .filter(). This ensures that every search—real‑time by user input—is powered by Fuse.js’s indexed search.
- **Enhanced Search Configuration:** Configured Fuse.js to search across multiple keys (file name, uploader, and tags) so that users can find files based on any of these properties.

---

## Changes 4/11/2025

- Fixed fileDragDrop issue from previous update.
- Fixed User Panel height changing unexpectedly on mouse over.
- Improved JS file comments for better documentation.
- Fixed userPermissions not updating after initial setting.
- Disabled folder and file sharing for readOnly users.
- Moved change password close button to the top right of the modal.
- Updated upload regex pattern to be Unicode‑enabled and added additional security measures. [(#19)](https://github.com/error311/FileRise/issues/19)
- Updated filename, folder, and username regex acceptance patterns.
- Updated robthree/twofactorauth to v3 and endroid/qr-code to v5
- Updated TOTP integration (namespace, enum, QR provider) accordingly
- Updated docker image from 22.04 to 24.04 <https://github.com/error311/filerise-docker>
- Ensure consistent session behavior
- Fix totp_setup.php to use header-based CSRF token verification

---

## Shift Key Multi‑Selection Changes 4/10/2025 v1.1.1

- **Implemented Range Selection:**
  - Modified the `toggleRowSelection` function so that when the Shift key is held down, all rows between the last clicked (anchor) row (stored as `window.lastSelectedFileRow`) and the currently clicked row are selected.
- **Modifier Handling:**
  - Regular clicks (or Ctrl/Cmd clicks) simply toggle the clicked row without clearing other selections.
- **Prevented Default Browser Behavior:**
  - Added `event.preventDefault()` in the Shift‑click branch to avoid unwanted text selection.
- **Maintaining the Anchor:**
  - The last clicked row is stored for future range selections.

## Total Files and File Size Summary

- **Size Calculation:**
  - Created `parseSizeToBytes(sizeStr)` to convert file size strings (e.g. `"456.9KB"`, `"1.2 MB"`) into a numerical byte value.
  - Created `formatSize(totalBytes)` to format a byte value into a human‑readable string (choosing between Bytes, KB, MB, or GB).
  - Created `buildFolderSummary(filteredFiles)` to:
    - Sum the sizes of all files (using `parseSizeToBytes`).
    - Count the total number of files.
- **Dynamic Display in `loadFileList`:**
  - Updated `loadFileList` to update a summary element (with `id="fileSummary"`) inside the `#fileListActions` container when files are present.
  - When no files are found, the summary element is hidden (setting its `display` to `"none"` or clearing the container).
- **Responsive Styling:**
  - Added CSS media queries to the `#fileSummary` element so that on small screens it is centered and any extra side margins are removed. Dark and light mode supported.

- **Other changes**

  - `shareFolder.php` updated to display format size.
  - Fix to prevent the filename text from overflowing its container in the gallery view.
  - Reduced header height.
  - Create Folder changed to Material Icon `create_new_folder`

---

## Folder Sharing Feature - Changelog 4/9/2025 v1.1.0

### New Endpoints

- **createFolderShareLink.php:**  
  - Generates secure, expiring share tokens for folders (with an optional password and allow-upload flag).  
  - Stores folder share records separately from file shares in `share_folder_links.json`.  
  - Builds share links that point to **shareFolder.php**, using a proper BASE_URL or the server’s IP when a default placeholder is detected.

- **shareFolder.php:**  
  - Serves shared folders via GET requests by reading tokens from `share_folder_links.json`.
  - Validates token expiration and password (if set).
  - Displays folder contents with pagination (10 items per page) and shows file sizes in megabytes.
  - Provides navigation links (Prev, Next, and numbered pages) for folder listings.
  - Includes an upload form (if allowed) that redirects back to the same share page after upload.
  
- **downloadSharedFile.php:**  
  - A dedicated, secure download endpoint for shared files.
  - Validates the share token and ensures the requested file is inside the shared folder.
  - Serves files using proper MIME types and Content-Disposition headers (inline for images, attachment for others).

- **uploadToSharedFolder.php:**  
  - Handles file uploads for public folder shares.
  - Enforces file size limits and file type whitelists.
  - Generates unique filenames (with a unique prefix) to prevent collisions.
  - Updates metadata for the uploaded file (upload date and sets uploader as "Outside Share").
  - Redirects back to **shareFolder.php** after a successful upload so the file listing refreshes.

### New Front-End Module

- **folderShareModal.js:**  
  - Provides a modal interface for users to generate folder share links.
  - Includes expiration selection, optional password entry, and an allow-upload checkbox.
  - Uses the **createFolderShareLink.php** endpoint to generate share links.
  - Displays the generated share link with a “copy to clipboard” button.

---

## Changes 4/8/2025

**May have missed some stuff or could have bugs. Please report any issue you may encounter.**

- **i18n Integration:**
  - Implemented a semi-complete internationalization (i18n) system for all user-facing texts in FileRise.
  - Created an `i18n.js` module containing a translations object with full keys for English (en), Spanish (es), and French (fr).
  - Updated JavaScript code to replace hard-coded strings with the `t()` translation function.
  - Enhanced HTML and modal templates to support dynamic language translations using data attributes (data-i18n-key, data-i18n-placeholder, etc.).

- **Language Dropdown & Persistence:**
  - Added a language dropdown to the user panel modal allowing users to select their preferred language.
  - Persisted the selected language in localStorage, ensuring that the preferred language is automatically applied on page refresh.
  - Updated main.js to load and set the user’s language preference on DOMContentLoaded by calling `setLocale()` and `applyTranslations()`.

- **Bug Fixes & Improvements:**
  - Fixed issues with evaluation of translation function calls in template literals (ensured proper syntax with `${t("key")}`).
  - Updated the t() function to be more defensive against missing keys.
  - Provided instructions and code examples to ensure the language change settings are reliably saved and applied across sessions.

- **ZIP Download Flow**
  - Progress Modal: In the ZIP download handler (confirmDownloadZip), added code to show a progress modal (with a spinning icon) as soon as the user confirms the download and before the request to create the ZIP begins. Once the blob is received or an error occurs, we hide the progress modal.
  - Inline Handlers and Global Exposure: Ensured that functions like confirmDownloadZip are attached to the global window object (or called via appropriate inline handlers) so that the inline onclick events in the HTML work without reference errors.

- **Single File Download Flow**
  - Modal Popup for Single File: Replaced the direct download link for single files with a modal-driven flow. When the download button is clicked, the openDownloadModal(fileName, folder) function is called. This stores the file details and shows a modal where the user can confirm (or edit) the file name.
  - Confirm Download Function: When the user clicks the Download button in the modal, the confirmSingleDownload() function is called. This function constructs a URL for download.php (using GET parameters for folder and file), fetches the file as a blob, and triggers a download using a temporary anchor element. A progress modal is also used here to give feedback during the download process.

- **Zip Extraction**
  - Reused Zip Download modal to use same progress Modal Popup with Extracting files.... text.

---

## Changes 4/7/2025 v1.0.9

- TOTP one time recovery code added
- fix(security): mitigate CodeQL alerts by adding SRI attributes and sanitizing DOM content

---

## Changes 4/6/2025 v1.0.8

**May need to log out and log back in if using remember me**  

Changelog: Modularize fileManager.js

1. **fileListView.js**  
 • Extracted all table/gallery rendering logic (loadFileList, renderFileTable, renderGalleryView, sortFiles, date parsing, pagination).  
 • Kept global helpers on window (changePage, changeItemsPerPage).  
 • Added explicit re‑binding of context‑menu and drag‑drop handlers after each render.  
2. **filePreview.js**  
 • Moved “Preview” and “Share” modal code here (previewFile, openShareModal, plus displayFilePreview helper).  
 • Exposed window.previewFile for inline onclick compatibility.  
3. **fileEditor.js**  
 • Isolated CodeMirror editor logic (editFile, saveFile, sizing, theme toggles).  
 • Exported utility functions (getModeForFile, adjustEditorSize, observeModalResize).  
4. **fileDragDrop.js**  
 • Encapsulated all drag‑start and folder drag/drop handlers (fileDragStartHandler, folderDragOverHandler, etc.).  
5. **fileMenu.js** (formerly contextMenu.js)  
 • Centralized right‑click context menu construction and binding (showFileContextMenu, fileListContextMenuHandler, bindFileListContextMenu).  
 • Now calls the correct single vs. multi‑tag modals.  
6. **fileActions.js**  
 • Consolidated all “Delete”, “Copy”, “Move”, “Download Zip”, “Extract Zip”, “Rename” workflows and their modals.  
 • Exposed initFileActions() to wire up toolbar buttons on page load.  
7. **fileManager.js** (entry point)  
 • Imports all the above modules.  
 • On DOM ready: calls initFileActions(), attaches folder tree drag/drop, and global key handlers.

Changelog: OIDC, Basic Auth & TOTP Integration

1. **auth.php (OIDC)**  
 • Detects callback via `?code` or `?oidc=callback`.  
 • Checks for a TOTP secret after OIDC auth, stores pending login in session, redirects with `?totp_required=1`.  
 • Finalizes session only after successful TOTP verification.  

2. **login_basic.php (Basic Auth)**  
 • After password verification, checks for TOTP secret.  
 • Stores pending login & secret in session, redirects to TOTP modal.  
 • Completes session setup only after TOTP verification.  

3. **authModals.js & auth.js**  
 • Detect `?totp_required=1` and open the TOTP modal.  
 • Override `showToast` to suppress “Please log in…” during TOTP.  
 • Wrap `openTOTPLoginModal` to disable Basic/OIDC buttons (but keep form-login visible).  
 • On invalid TOTP code, keep modal open, clear input, and refocus for retry.  

4. **totp_verify.php**  
 • Consolidates login and setup TOTP flows in one endpoint.  
 • Enforces CSRF token and authentication guard.  
 • Verifies TOTP, regenerates session on success, and clears pending state.  
 • Production‑hardened: secure cookies, CSP header, rate‑limiting (5 attempts), standardized JSON responses, and robust error handling.

---

## changes 4/4/2025

- fix(`download.php`): mitigate path traversal vulnerability by validating folder and file inputs
- Fixed OIDC login button DOM.
- Fixed userPermissions calling username before declared.
- Fixed config.php loadUserPermissions issue.
- Chain Initialization After CSRF Token Is Loaded
- loadCsrfTokenWithRetry

---

## changes 4/3/2025

Change Log for dragAndDrop.js Enhancements

- **Header Drop Zone Integration:**
  - Added a new header drop zone (`#headerDropArea`) to support dragging cards (Upload and Folder Management) into the header.
  - Created functionality to display a compact Material icon in the header when a card is dropped there.

- **Modal Popup for Header Cards:**
  - Implemented a modal overlay that displays the full card when the user hovers or clicks the header icon.
  - Added toggle functionality so that the modal can be locked open or auto-hide based on mouse interactions.

- **State Preservation via Hidden Container:**
  - Introduced a hidden container (`#hiddenCardsContainer`) to preserve the original state of the Upload and Folder Management cards.
  - Modified logic so that instead of removing these cards from the DOM when dropped into the header, they are moved to the hidden container.
  - Updated modal show/hide functions to move the card from the hidden container into the modal (and back), ensuring interactive elements (e.g., folder tree, file selection) remain fully initialized and retain their state across page refreshes.

- **Local Storage Integration for Header Order:**
  - Added `saveHeaderOrder()` and `loadHeaderOrder()` functions to persist the header drop zone order.
  - Integrated header order saving/updating with drag-and-drop events so that header placements are maintained after refresh.

- **General Drag & Drop Enhancements:**
  - Maintained smooth drag-and-drop animations and reflow for all drop zones (sidebar, top, and header).
  - Ensured existing functionalities (like file uploads and folder tree interactions) work seamlessly alongside the new header drop zone.
  
## Brief Description

The enhancements extend the existing drag-and-drop functionality by adding a header drop zone where cards are represented by a compact Material icon. To preserve interactive state (such as the folder tree’s current folder or file input functionality) across page refreshes, the original cards are never fully removed from the DOM. Instead, they are moved into a hidden container, and when a user interacts with the header icon, the card is temporarily transferred into a modal overlay for full interaction. When the modal is closed, the card is returned to the hidden container, ensuring that its state remains intact. Additionally, header order is saved to local storage so that user-customized layouts persist across sessions.

---

## changes 4/2/2025

- **Admin Panel - User Permissions**
  - folderOnly - User gets their own root folder.
  - readOnly - User can't delete, rename, move, copy and other endpoints are blocked.
  - disableUpload - User can't upload any files.
  - Encrypted json 'userPermissions.json'
  - Created 'updateUserPermissions.php' & 'getUserPermissions.php'

- **TOTP Confirmation**
  - Must confirm code before it will enable TOTP.
  - 'totp_verify.php' & 'totp_disable.php' were created

- **Basic Auth & OIDC fixes**
  - Fixed session issues
  - Improvements for both Basic Auth & OIDC

- Path Normalization
- Folder Rendering Adjustments
- Folder Creation Logic adjusted
- User Panel added username
- Admin Panel added version number
- Metadata Adjustments
- Toast moved to bottom right
- Help function 'loadUserPermissions()'
- 'auth.js' split into 'authModals.js'
- Empty 'createdTags.json' added
- Enable MKV video playback if supported
- Custom toast opacity increased
- Fixed fileDragStartHandler to work with tagFiles
- And more

---

## changes 3/31/2025

- **Chunk merging logic updated to attempt to clear any resumable issues**

- **Implemented Video Progress Saving and Resuming**

- **Context Menu Tagging:**  
  - "Tag File" option for single files; "Tag Selected" for multiple files.
- **Tagging Modals:**  
  - Separate modals for single‑ and multi‑file tagging with custom dropdowns.
- **Global Tag Store:**  
  - Reusable tags persisted via `createdTags.json`; dropdown shows tag color and remove icon.
- **Unified Search:**  
  - Single search box filters files by name or associated tag(s).

- **saveFileTag.php:**  
  - Saves file-specific tags and updates global tags (supports removal).
- **getFileList.php:**  
  - Returns tag data for each file and the global tag list.

- Added `openMultiTagModal()` for batch tagging.
- Custom dropdowns with colored tag previews and removal buttons.
- Filtering logic updated in table and gallery views to combine file name and tag searches.

## changes 3/30/2025

- **New Feature:** Generates a QR code for TOTP setup using the Endroid QR Code library.
- **TOTP Secret Management:**  
  - Retrieves the current user's TOTP secret from the users file.
  - If no secret exists, generates a new one using RobThree\Auth\TwoFactorAuth and stores it (encrypted).
- **Global OTPAuth URL Integration:**  
  - Checks for a global OTPAuth URL in the admin configuration.
  - If provided, replaces the `{label}` and `{secret}` placeholders in the URL template; otherwise, falls back to a default otpauth URL.
- **Security:**  
  - Enforces session authentication.
  - Verifies the CSRF token passed via GET parameters.

- **New Feature:** Handles AJAX requests to update the user’s TOTP settings from the User Panel.
- **TOTP Enable/Disable Handling:**  
  - If TOTP is disabled, clears the user's TOTP secret from the users file.
  - If TOTP remains enabled, leaves the stored secret intact.
- **Security:**  
  - Validates user authentication and CSRF token before processing the update.
- **Response:**  
  - Returns a JSON response indicating whether TOTP has been enabled or disabled successfully.

- **New TOTP Settings Section:**  
  - A "TOTP Settings" fieldset has been added to the User Panel modal.
- **Automatic TOTP Setup Trigger:**  
  - When the "Enable TOTP" checkbox is checked, it automatically triggers the TOTP Setup Modal to display the QR code.
- **State Management**  
- **UI Improvements:**  
  - All modals (User Panel, TOTP Setup, and TOTP Login) now support dark mode styling.

- **Error Handling & Security:**  
  - Enhanced error handling across all new TOTP-related endpoints.
  - Added extra CSRF and authentication checks to improve security.
- **User Experience:**  
  - Streamlined the onboarding process for TOTP by integrating automatic modal triggers and real-time configuration updates.

---

## changes 3/29/2025

**Frontend (JavaScript)**  

**File:** `auth.js`

- **Added OIDC Login Flow**
  - Created a dedicated OIDC login button (`oidcLoginBtn`).
  - Redirects users to OIDC authentication via `auth.php?oidc`.

- **Admin Panel Button**
  - Added an “Admin Panel” button (`adminPanelBtn`) with a Material icon (`admin_panel_settings`).
  - Inserted Admin Panel button directly after the Restore button in the header.

- **Admin Panel Modal**
  - Built a fully-featured admin panel modal with fields to edit:
    - OIDC Provider URL
    - Client ID
    - Client Secret
    - Redirect URI
  - Options to disable Form Login, Basic Auth, or OIDC login methods individually.
  - Integrated real-time constraint enforcement to ensure at least one authentication method is always enabled.
  - Saved admin preferences into local storage and backend (via `updateConfig.php`).

- **Dynamic UI Updates**
  - Added functions (`updateLoginOptionsUI`, `updateLoginOptionsUIFromStorage`) to dynamically show/hide login elements based on admin preferences.

⸻

**Backend (PHP)**  

**File:** `auth.php`

- **OIDC Authentication**
  - Integrated Jumbojett’s OpenID Connect client to handle OIDC flows.
  - Reads OIDC configuration from an encrypted JSON file (`adminConfig.json`).
  - Redirects users to OIDC provider and handles callbacks properly, authenticating users and initiating PHP sessions.

- **Security Enhancements**
  - Implemented robust error handling for authentication failures.
  - Session regeneration after successful login to mitigate session fixation risks.

**Configuration Handling**  

**File:** `getConfig.php`

- **Secure Configuration Retrieval**
  - Retrieves encrypted OIDC configuration from disk.
  - Decrypts and sends JSON configuration securely to the frontend.
  - Defaults provided if configuration does not exist.

**File:** `updateConfig.php`

- **Secure Configuration Updates**
  - Strictly checks for authenticated admin sessions and validates CSRF tokens.
  - Validates and sanitizes user input thoroughly (OIDC URL, client ID, secret, redirect URI).
  - Updates encrypted configuration file securely, ensuring atomic writes (`LOCK_EX`).

- **Consistent Styling**
  - Modal dynamically adjusts styling based on dark/light modes.
  - Improved accessibility with clear icons, visual hierarchy, and structured form fields.

- **Enhanced Feedback**
  - Toast notifications clearly communicate success/error messages for user/admin actions.

⸻

**Security and Best Practices**  

- OIDC credentials are securely stored in an encrypted JSON configuration file.
- Implemented proper sanitization and validation of input data.
- Protected sensitive admin routes (`updateConfig.php`) with CSRF validation and strict access control.

⸻

**Possible Improvements**  

- **OIDC Logout Support:** Add explicit logout from OIDC providers.
- **OIDC Discovery Endpoint:** Automatically fetch provider details from `.well-known/openid-configuration`.
- **Advanced User Mapping:** Allow administrators to map OIDC claims to internal user roles dynamically.

---

## changes 3/27/2025

- Basic Auth added for login.
- Audio files supported for playback mp3|wav|m4a|ogg|flac|aac|wma|opus

---

## changes 3/26/2025

- New name change FileRise - Elevate your file management.
- Animated logo that rises up once for 3 seconds and falls back down
- New Side Bar and Top Bar drop areas
  - Drag and Drop Upload & Folder Management cards
  - Vertical slide up effect when dropping cards
- Fixed double root folders when only root folder exist
- Adjusted side bar drop zone

---

## changes 3/25/2025

- **Context Menu Enhancements:**
  - **Right‑Click Context Menu:**
    - Added context menu support for file list rows so that right‑clicking shows a custom menu.
    - When multiple files are selected, options like “Delete Selected”, “Copy Selected”, “Move Selected”, “Download Zip” are shown.
    - When a file with a “.zip” extension is among the selections, an “Extract Zip” option is added.
  - **Single File Options:**
    - For a single selected file, additional items (“Preview”, “Edit”, and “Rename”) are appended.
    - The “Edit” option appears only if `canEditFile(file.name)` returns true.
- **Keyboard Shortcuts:**
  - **Delete Key Shortcut:**
    - Added a global keydown listener to detect the Delete (or Backspace on Mac) key.
    - When pressed (and if no input/textarea is focused) with files selected, it triggers `handleDeleteSelected()` to open the delete confirmation modal.
- **Modals & Enter-Key Handling:**
  - **attachEnterKeyListener Update:**
    - Modified the function to use the “keydown” event (instead of “keypress”) for better reliability.
    - Ensured the modal is made focusable (by setting a `tabindex="-1"`) and focused immediately after being displayed.
    - This update was applied to modals for rename, download zip, and delete operations.
  - **Delete Modal Specific:**
    - It was necessary to call `attachEnterKeyListener` for the delete modal after setting its display to “block” to ensure it captures the Enter key.
- **File Editing Adjustments:**
  - **Content-Length Check:**
    - Modified the `editFile` function so that it only blocks files when the Content-Length header is non‑null and greater than 10 MB.
    - This change allows editing of 0 KB files (or files with Content-Length “0”) without triggering the “File too large” error.

- **Context Menu for Folder Manager:**
  - Provided a separate implementation for a custom context menu for folder manager elements.
  - Bound the context menu to both folder tree nodes (`.folder-option`) and breadcrumb links (`.breadcrumb-link`) so that right‑clicking on either triggers a custom menu.
  - The custom menu for folders includes actions for “Create Folder”, “Rename Folder”, and “Delete Folder.”
  - Added guidance to ensure that breadcrumb HTML elements contain the appropriate class and `data-folder` attribute.
- **Keyboard Shortcut for Folder Deletion (Suggestion):**
  - Suggested adding a global keydown listener in `folderManager.js` to trigger folder deletion (via `openDeleteFolderModal()`) when Delete/Backspace is pressed and a folder other than “root” is selected.

- **Event Listener Timing:**
  - Ensured that context menu and key event listeners are attached after the corresponding DOM elements are rendered.
  - Added explicit focus calls (and `tabindex` attributes) for modals to capture keyboard events.

---

## changes 3/24/2025

### config.php

- **Encryption Functions Added:**
  - Introduced `encryptData()` and `decryptData()` functions using AES‑256‑CBC to encrypt and decrypt persistent tokens.
- **Encryption Key Handling:**
  - Added code to load the encryption key from an environment variable (`PERSISTENT_TOKENS_KEY`) with a fallback default.
- **Persistent Token Auto-Login:**
  - Modified the auto-login logic to check for a `remember_me_token` cookie.
  - If the persistent tokens file exists, it now reads and decrypts its content before decoding JSON.
  - If a token is expired, the code removes the token, re-encrypts the updated array, writes it back to disk, and clears the cookie.
- **Cookie and Session Settings:**
  - No major changes aside from integrating the encryption functionality into the token handling.

### auth.php

- **Login Process and “Remember Me” Functionality:**
  - When “Remember me” is checked, generates a secure random token.
  - Loads the persistent tokens file (if it exists), decrypts its content, and decodes the JSON.
  - Inserts the new token (with associated username and expiry) into the persistent tokens array.
  - Encrypts the updated tokens array and writes it back to the file.
  - Sets the `remember_me_token` cookie using the `$secure` flag and expiry.
- **Authentication & Brute Force Protection:**
  - The authentication logic and brute-force protection remain largely unchanged.

### logout.php

- **Persistent Token Removal:**
  - If a `remember_me_token` cookie exists, the script loads the persistent tokens file, decrypts its content, removes the token if present, re-encrypts the array, and writes it back.
- **Cookie Clearance and Session Destruction:**
  - Clears the `remember_me_token` cookie.
  - Destroys session data as before.

### networkUtils.js

- **Fetch Wrapper Enhancements:**
  - Modified `sendRequest()` to clone the response before attempting to parse JSON.
  - If JSON parsing fails (e.g., because of unexpected response content), the cloned response is used to read the text, preventing the “Body is disturbed or locked” error.
- **Error Handling Improvements:**
  - Improved error handling by ensuring the response body is read only once.

---

## changes 3/23/2025 v1.0.1

- **Resumable File Upload Integration and Folder Support**
  - **Legacy Drag-and-Drop Folder Uploads:**
    - Supports both file and folder uploads via drag-and-drop.
    - Recursively traverses dropped folders to extract files.
    - Uses original XHR-based upload code for folder uploads so that files are placed in the correct folder (i.e. based on the current folder in the app’s folder tree).
  - **Resumable.js for File Picker Uploads:**
    - Integrates Resumable.js for file uploads via the file picker.
    - Provides pause, resume, and retry functionality:
    - Pause/Resume: A pause/resume button is added for each file selected via the file picker. When the user clicks pause, the file upload pauses and the button switches to a “play” icon. When the user clicks it again, the system triggers a resume sequence (calling the upload function twice to ensure proper restart).
    - Retry: If a file upload encounters an error, the pause/resume button changes to a “replay” icon, allowing the user to retry the upload.
    - During upload, the UI displays the progress percentage along with the calculated speed (bytes/KB/MB per second).
    - Files are previewed using material icons for non-image files and actual image previews for image files (using a helper function that creates an object URL for image files).
  - **Temporary Chunk Folder Removal:**
    - When a user cancels an upload via the remove button (X), a POST request is sent to a PHP endpoint (removeChunks.php) that:
    - Validates the CSRF token.
    - Recursively deletes the temporary folder (which stores file chunks) from the uploads directory.
  - **Additional Details:**
    - The file list UI remains visible (instead of auto-disappearing after 5 seconds) if there are any files still present or errors, ensuring that users can retry failed uploads.
    - The system uses a chunk size of 3MB and supports multiple simultaneous uploads.
    - All endpoints include CSRF protection and input validation to ensure secure operations.

---

## changes 3/22/2025

- Change Password added and visibile to all users.
- Brute force protection added and a log file for fail2ban created
- Fix add user and setup user issue
- Added folder breadcrumb with drag and drop support

---

## changes 3/21/2025 v1.0.0

- **Trash Feature Implementation**
  - Added functionality to move deleted files to a Trash folder.
  - Implemented trash metadata storage (trash.json) capturing original folder, file name, trashed timestamp, uploader, and deletedBy.
  - Developed restore feature allowing admins to restore individual or all files from Trash.
  - Developed delete feature allowing permanent deletion (Delete Selected and Delete All) from Trash.
  - Implemented auto-purge of trash items older than 3 days.
  - Updated trash modal design for better user experience.
  - Incorporated material icons with tooltips in restore/delete buttons.
  - Improved responsiveness of the trash modal with a centered layout and updated CSS.
  - Fixed issues where trashed files with missing metadata were not restored properly.
  - Resolved problems with the auto-purge mechanism when trash.json was empty or contained unexpected data.
  - Adjusted admin button logic to correctly display the restore button for administrators.
  - Improved error handling on restore and delete actions to provide more informative messages to users.
- **Other changes**
  - CSS adjusted (this needs to be refactored)
  - Fixed setup mode CSRF issue in addUser.php
  - Adjusted modals buttons in index.html & folderManager.js
  - Changed upload.php safe pattern
  - Hide trash folder
  - Reworked auth.js

---

## changes 3/20/2025

- **Drag & Drop Feature**
  - For a single file: shows a file icon alongside the file name.
  - For multiple files: shows a file icon and a count of files.
  - Styling Adjustments:
  - Modified drag image styling (using inline-flex, auto width, and appropriate padding) so that the drag image only sizes to its content and does not extend off the screen.
  - Revised the folder drop handler so that it reads the array of file names from the drag data and sends that array (instead of a single file name) to the server (moveFiles.php) for processing.
  - Attached dragover, dragleave, and drop event listeners to folder tree nodes (the elements with the class folder-option) to enable a drop target.
  - Added a global dragover event listener (in main.js) that auto-scrolls the page when the mouse is near the top or bottom of the viewport during a drag operation. This ensures you can reach the folder tree even if you’re far down the file list.

---

## changes 3/19/2025

## Session & Security Enhancements

- **Secure Session Cookies:**  
  - Configured session cookies with a 2-hour lifetime, HTTPOnly, and SameSite settings.
  - Regenerating the session ID upon login to mitigate session fixation.
- **CSRF Protection:**  
  - Ensured the CSRF token is generated in `config.php` and returned via a `token.php` endpoint.
  - Updated front-end code (e.g. in `main.js`) to fetch the CSRF token and update meta tags.
- **Session Expiration Handling:**  
  - Updated the `loadFileList` and other functions to check for HTTP 401 responses and trigger a logout or redirect if the session has expired.

## File Management Improvements

### Unique Naming to Prevent Overwrites

- **Copy & Move Operations:**  
  - Added a helper function `getUniqueFileName()` to both `copyFiles.php` and `moveFiles.php` that checks for duplicates and appends a counter (e.g., “ (1)”) until a unique filename is determined.
  - Updated metadata handling so that when a file is copied/moved and renamed, the corresponding metadata JSON (per-folder) is updated using the new unique filename.
- **Rename Functionality:**  
  - Updated `renameFile.php` to:
    - Allow filenames with parentheses by updating the regex.
    - Check if a file with the new name already exists.
    - Generate a unique name using similar logic if needed.
    - Update folder-specific metadata accordingly.

### Metadata Management

- **Per-Folder Metadata Files:**  
  - Changed metadata storage so that each folder uses its own metadata file (e.g., `root_metadata.json` for the root folder and `FolderName_metadata.json` for subfolders).
  - Updated metadata file path generation functions to replace slashes, backslashes, and spaces with dashes.

## Gallery / Grid View Enhancements

- **Gallery (Grid) View:**  
  - Added a toggle option to switch between a traditional table view and a gallery view.
  - The gallery view arranges image thumbnails in a grid layout with configurable column options (e.g., 3, 4, or 5 columns).
  - Under each thumbnail, action buttons (Download, Edit, Rename, Share) are displayed for quick access.
- **Preview Modal Enhancements:**  
  - Updated the image preview modal to include navigation buttons (prev/next) for browsing through images.
  - Improved scaling and styling of preview modals for a better user experience.

## Share Link Functionality

- **Share Link Generation (createShareLink.php):**  
  - Generate shareable links for files with:
    - A secure token.
    - Configurable expiration times (including options for 30, 60, 120, 180, 240 minutes, and a 1-day option).
    - Optional password protection (passwords are hashed).
  - Store share links in a JSON file (`share_links.json`) with details (folder, file, expiration timestamp, hashed password).
- **Share Endpoint (share.php):**  
  - Validate tokens, expiration, and passwords.
  - Serve files inline for images or force download for other file types.
  - Share URL is configurable via environment variables or auto-detected from the server.
- **Front-End Configuration:**  
  - Created a `token.php` endpoint that returns CSRF token and SHARE_URL.
  - Updated the front-end (in `main.js`) to fetch configuration data and update meta tags for CSRF and share URL, allowing index.html to remain static.

## Apache & .htaccess / Server Security

- **Disable Directory Listing:**  
  - Recommended adding an .htaccess file (e.g., in `uploads/`) with `Options -Indexes` to disable directory indexing.
- **Restrict Direct File Access:**  
  - Protected sensitive files (e.g., users.txt) via .htaccess.
  - Filtered out hidden files (files beginning with a dot) from the file list in `getFileList.php`.
- **Proxy Download:**  
  - A proxy download mechanism has been implemented (via endpoints like `download.php` and `downloadZip.php`) so that every file download request goes through a PHP script. This script validates the session and CSRF token before streaming the file, ensuring that even if a file URL is guessed, only authenticated users can access it.

---

## changes 3/18/2025

- **CSRF Protection:** All state-changing endpoints (such as those for folder and file operations) include CSRF token validation to ensure that only legitimate requests from authenticated users are processed.

---

## changes 3/17/2025

- refactoring/reorganize domUtils, fileManager.js & folerManager.js

---

## changes 3/15/2025

- Preview video, images or PDFs added
- Different material icons for each
- Custom css to adjust centering
- Persistent folder tree view
- Fixed folder tree alignment
- Persistent last opened folder

---

## changes 3/14/2025

- Style adjustments
- Folder/subfolder upload support
- Persistent UI elements Items Per Page & Dark/Light modes.
- File upload scrollbar list
- Remove files from upload list

---

## changes 3/11/2025

- CSS Refactoring
- Dark / Light Modes added which automatically adapts to the operating system’s theme preference by default, with a manual toggle option.
- JS inlines moved to CSS

---

## changes 3/10/2025

- File Editing Enhancements:
  - Integrated CodeMirror into the file editor modal for syntax highlighting, line numbers, and adjustable font size.
  - Added zoom in/out controls (“A-” / “A+”) in the editor modal to let users adjust the text size and number of visible lines.
  - Updated the save function to retrieve edited content from the CodeMirror instance (using editor.getValue()) instead of the underlying textarea.
- Image Preview Improvements:
  - Added a new “Preview” button (with a Material icon) in the Actions column for image files.
  - Implemented an image preview modal that centers content using flexbox, scales images using object-fit: contain, and maintains the original aspect ratio.
  - Fixed URL encoding for subfolder paths so that images in subfolders (e.g. NewFolder2/Vita) load correctly without encoding slashes.
- Download ZIP Modal Updates:
  - Replaced the prompt-based download ZIP with a modal dialog that allows users to enter a custom name for the ZIP file.
  - Updated the modal logic to ensure proper flow (cancel/confirm) and pass the custom filename to the download process.
- Folder URL Handling:
  - Modified the folder path construction in the file list rendering to split folder names into segments and encode each segment individually. This prevents encoding of slashes, ensuring correct URLs for files in subfolders.
- General UI & Functionality:
  - Ensured that all global functions (e.g., toggleRowSelection, updateRowHighlight, and sortFiles) are declared and attached to window so that inline event handlers can access them.
  - Maintained responsive design, preserving existing features such as pagination, sorting, batch operations (delete, copy, move), and folder management.
  - Updated event listener initialization to work with new modal features and ensure smooth UI interactions.

---

## changes 3/8/2025

- Validation was added in endpoints.
- Toast notifications were implemented in domUtils.js and integrated throughout the app.
- Modals replaced inline prompts and confirms for rename, create, delete, copy, and move actions.
- Folder tree UI was added and improved to be interactive plus reflect the current state after actions.

---

## changes 3/7/2025

- **Module Refactoring:**
  - Split the original `utils.js` into multiple ES6 modules for network requests, DOM utilities, file management, folder management, uploads, and authentication.
  - Converted all code to ES6 modules with `import`/`export` syntax and exposed necessary functions globally.
- **File List Rendering & Pagination:**
  - Implemented pagination in `fileManager.js` to allow displaying 10, 20, 50, or 100 items per page.
  - Added global functions (`changePage` and `changeItemsPerPage`) for pagination control.
  - Added a pagination control section below the file list table.
- **Date Sorting Enhancements:**
  - Created a custom date parser (`parseCustomDate`) to convert date strings.
  - Adjusted the parser to handle two-digit years by adding 2000.
  - Integrated the parser into the sorting function to reliably sort “Date Modified” and “Upload Date” columns.
- **File Upload Improvements:**
  - Enabled multi-file uploads with individual progress tracking (visible for the first 10 files).
  - Ensured that the file list refreshes immediately after uploads complete.
  - Kept the upload progress list visible for a configurable delay to allow users to verify upload success.
  - Reattached event listeners after the file list is re-rendered.
- **File Action Buttons:**
  - Unified button state management so that Delete, Copy, and Move buttons remain visible as long as files exist, and are only enabled when files are selected.
  - Modified the logic in `updateFileActionButtons` and removed conflicting code from `initFileActions`.
  - Ensured that the folder dropdown for copy/move is hidden when no files exist.
- **Rename Functionality:**
  - Added a “Rename” button to the Actions column for every file.
  - Implemented a `renameFile` function that prompts for a new name, calls a backend script (`renameFile.php`) to perform the rename, updates metadata, and refreshes the file list.
- **Responsive & UI Tweaks:**
  - Applied CSS media queries to hide secondary columns on small screens.
  - Adjusted file preview and icon styling for better alignment.
  - Centered the header and optimized the layout for a clean, modern appearance.
  
*This changelog and feature summary reflect the improvements made during the refactor from a monolithic utils file to modular ES6 components, along with enhancements in UI responsiveness, sorting, file uploads, and file management operations.*

---

## Changes 3/4/2025

- Copy & Move functionality added  
- Header Layout  
- Modal Popups (Edit, Add User, Remove User) changes  
- Consolidated table styling  
- CSS Consolidation  
- assets folder  
- additional changes and fixes

---

## Changes 3/3/2025

- folder management added  
- some refactoring  
- config added USERS_DIR & USERS_FILE  
