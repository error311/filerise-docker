# multi-file-upload-editor-docker

## dockerfile

- Install Apache, PHP, required packages and update
- adds multi file upload editor to /var/www directory (<https://github.com/error311/multi-file-upload-editor>)

---

## start.sh

- Permissions changes
- Allows configuration changes with env variables for apache & multi file upload editor

---

## changelog

## changes 3/22/2025
- Change Password added and visibile to all users.
- Brute force protection added and a log file for fail2ban created
- Fix add user and setup user issue
- Added folder breadcrumb with drag and drop support

## changes 3/21/2025

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
