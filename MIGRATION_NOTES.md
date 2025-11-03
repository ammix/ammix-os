# BlueBuild to Ublue Template Migration

## Summary

Successfully migrated from BlueBuild recipe.yml format to the official ublue image template format.

## Changes Made

### 1. Created `build_files/packages.list`
- **Purpose**: Centralized package definitions organized by category
- **Structure**: Bash arrays for each category of packages
- **Benefits**: 
  - Easy to maintain and update
  - Clear organization by function
  - Simple to comment and document
  - Reusable across scripts if needed

### 2. Updated `build_files/build`
Key additions and improvements:

#### a. /opt Directory Fix (Two-part implementation)
**Part 1 - Setup (Lines 18-28):**
```bash
# Create directory structure
mkdir -p /var/opt
mkdir -p /usr/lib/opt

# Create symlink from /opt to /var/opt
if [[ ! -L /opt ]]; then
    rm -rf /opt
    ln -s /var/opt /opt
fi
```

**Part 2 - Application (After external RPM installation):**
```bash
# Symlink applications from /usr/lib/opt/* to /var/opt/*
SOURCE_DIR="/usr/lib/opt"
TARGET_DIR="/var/opt"

for dir in "$SOURCE_DIR/"*/; do
    if [ -d "$dir" ]; then
        dir_name=$(basename "$dir")
        if [ ! -L "$TARGET_DIR/$dir_name" ]; then
            ln -s "$dir" "$TARGET_DIR/$dir_name"
            echo "Created symlink for $dir_name"
        fi
    fi
done
```

**Why**: In OSTree/bootc systems:
1. Applications like Vivaldi and Filen install to `/usr/lib/opt/` (immutable)
2. `/opt` is a symlink to `/var/opt` (mutable)
3. We create symlinks from `/usr/lib/opt/*` → `/var/opt/*`
4. This makes apps accessible via `/opt/appname` → `/var/opt/appname` → `/usr/lib/opt/appname`

This two-step process ensures Vivaldi and Filen work correctly in the bootc environment.

#### b. Added LACT COPR Repository
```bash
dnf5 copr enable -y ilyaz/LACT
```
**Why**: Needed for the `lact` package (Linux AMDGPU Control Tool).

#### c. Package Installation with Categories
The script now sources `packages.list` and installs packages by category:
- System & CLI Tools
- Firmware
- Development Tools
- Containers & Virtualization
- Media & Graphics
- Terminals & Browsers
- Desktop & GNOME
- Input Methods
- Security & Authentication
- Storage & Backup
- Fonts

#### d. DNF5 Group Install Syntax
```bash
dnf5 group install -y --skip-unavailable "${group}"
```
**Installs**: Multimedia, Virtualization, Development Tools, Development Libraries, C Development

#### e. External RPM Installation
Handles external RPMs like Filen with proper URL installation.

## Package Mapping from BlueBuild Recipe

### Already in Current Build
- ✅ RPM Fusion (free, nonfree, tainted)
- ✅ Vivaldi repo
- ✅ Terra repos
- ✅ FFmpeg swap
- ✅ Multimedia codecs
- ✅ Cosign
- ✅ Firefox removal
- ✅ Systemd services (enabled/masked)
- ✅ gschema compilation
- ✅ Custom fonts installation

### Added from BlueBuild Recipe
- ✅ LACT COPR repository
- ✅ Cider (from Cider repo in files/etc/yum.repos.d/)
- ✅ All packages from your recipe organized into categories
- ✅ Group installs (multimedia, virtualization, development tools, etc.)
- ✅ Filen RPM from external URL
- ✅ VirtualBox with akmods support

## Key Differences from BlueBuild

1. **File Structure**: Separate package list file instead of YAML
2. **Script-based**: Uses bash scripts instead of Python modules
3. **Manual Repo Management**: Repos defined in files or added via dnf5 commands
4. **Explicit Control**: More granular control over installation order
5. **Custom Logic**: Can add custom bash logic anywhere in the process

## Repositories Configured

1. **RPM Fusion** (free, nonfree, tainted)
2. **Vivaldi** (from vivaldi-fedora.repo)
3. **Terra** (mesa enabled, nvidia disabled)
4. **Cider** (from files/etc/yum.repos.d/cider.repo)
5. **COPR**: 
   - bieszczaders/kernel-cachyos-addons
   - ilyaz/LACT

## Build Order

1. Copy files from files/ directory
2. Install dnf5
3. Setup /opt directory structure (Part 1 of opt fix)
4. Swap OpenCL package
5. Install RPM Fusion
6. Add Vivaldi repo
7. Enable COPR repos
8. Install Terra
9. Configure repo priorities
10. Install firmware (generic + specific)
11. Swap ffmpeg
12. Install multimedia codecs
13. Install categorized packages
14. Install external RPMs (Filen)
15. Apply /opt directory fix (Part 2 - symlink apps from /usr/lib/opt)
16. Install group packages
17. Install cosign
18. Remove unwanted packages
19. Install custom fonts
20. Compile gschema
21. Configure systemd services
22. Set Plymouth theme

## Testing Recommendations

1. **Build the image**: `just build`
2. **Test in VM**: `just build-vm` or `just build-iso`
3. **Verify packages**: Check that all expected packages are installed
4. **Test Vivaldi**: Ensure it launches correctly (opt fix)
5. **Test Filen**: Ensure it launches correctly (opt fix)
6. **Check services**: Verify enabled/masked services are correct

## Maintenance

To add new packages:
1. Edit `build_files/packages.list`
2. Add to appropriate category array
3. Rebuild image

To add new repos:
1. Either add .repo file to `files/etc/yum.repos.d/`
2. Or add dnf5 config-manager command to build script

## Notes

- The Cider repo is already present in files/etc/yum.repos.d/cider.repo
- VirtualBox requires akmods (handled in build_files/akmods script)
- Custom fonts (JetBrainsMono, Victor Mono) installed via build_files/fonts script
- Plymouth theme set to catppuccin-mocha (files in files/usr/share/plymouth/themes/)
- gschema overrides in files/usr/share/glib-2.0/schemas/ are automatically compiled
