# Bug Report for lofi.sh

## 1. Critical: Incorrect JSON escaping breaks metadata display

**Location:** `get_metadata_for_file` function.

**Description:**

The script uses `sed 's/"/\"/g'` to escape double quotes within the metadata (title, album, artist) before creating a JSON object with `printf`. However, the correct sed command to escape a double quote for JSON should be `sed 's/"/\\"/g'`.

The current implementation generates invalid JSON when a metadata field contains a double quote.

**Example:**

- **Song Title:** `My "Cool" Song`
- **Current `sed` command output for `printf`:** `{"title":"My "Cool" Song", ...}`
- **Resulting `printf` string:** `{"title":"My "Cool" Song", ...}` (This is invalid JSON)

When the `u_main` function later tries to parse this string with `jq`, it fails. As a result, the UI will display "Título Desconhecido", "Álbum Desconhecido", etc., instead of the correct metadata.

**Impact:**

High. This bug breaks the metadata display feature for any music file that has double quotes in its `title`, `album`, or `artist` tags.
