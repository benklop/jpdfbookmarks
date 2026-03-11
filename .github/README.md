# GitHub Workflows

## Build and Release AppImage

This workflow automatically builds an AppImage package for JPdfBookmarks and attaches it to GitHub releases.

### Trigger Events

1. **On Release Creation** - Automatically runs when a new release is created or published
   - The workflow builds the AppImage and uploads it as a release asset
   - The AppImage will appear in the release downloads

2. **Manual Trigger** - Can be manually triggered from the Actions tab
   - Useful for testing or building AppImage without creating a release
   - The AppImage is uploaded as a workflow artifact (available for 30 days)

### What the Workflow Does

1. **Checkout Code** - Clones the repository
2. **Setup Java** - Installs JDK 8 (compatible with Java 6 runtime requirement)
3. **Install Ant** - Installs Apache Ant build tool
4. **Build Components** - Builds all JPdfBookmarks components in order:
   - iText-2.1.7-patched
   - Bookmark
   - Colors
   - Utilities
   - ResourceHelper
   - CollapsingPanel
   - jpdfbookmarks_graphics
   - jpdfbookmarks_languages
   - iTextBookmarksConverter
   - jpdfbookmarks_core
5. **Download appimagetool** - Downloads the AppImage creation tool
6. **Build AppImage** - Creates the AppImage package
7. **Upload to Release** - Attaches the AppImage to the GitHub release

### Manual Workflow Trigger

To manually trigger the workflow:

1. Go to the "Actions" tab in the GitHub repository
2. Select "Build and Release AppImage" workflow
3. Click "Run workflow" button
4. Choose the branch and click "Run workflow"

The resulting AppImage will be available as a workflow artifact.

### Output

The workflow produces a file named: `jpdfbookmarks-{VERSION}-x86_64.AppImage`

Where `{VERSION}` is read from `jpdfbookmarks_core/src/it/flavianopetrocchi/jpdfbookmarks/jpdfbookmarks.properties`

### Requirements

- The workflow runs on Ubuntu latest
- No additional setup required in the repository
- Uses standard GitHub Actions and public actions from the marketplace
