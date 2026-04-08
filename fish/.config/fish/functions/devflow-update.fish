function devflow-update --description 'Refresh indices and list outdated packages'
    set -l total_outdated 0

    echo ""

    # ── Homebrew ──────────────────────────────────────
    echo (set_color cyan --bold)"  Homebrew"(set_color normal)
    if command -q brew
        brew update >/dev/null 2>&1
        set -l outdated_json (brew outdated --json=v2 2>/dev/null)
        set -l outdated_count (echo "$outdated_json" | jq '[.formulae // [] | length, .casks // [] | length] | add' 2>/dev/null)

        if test "$outdated_count" -gt 0 2>/dev/null
            echo "  ($outdated_count outdated)"
            echo "$outdated_json" | jq -r '.formulae // [] | .[] | "    \(.name)  \(.installed_versions[0]) → \(.current_version)"' 2>/dev/null
            echo "$outdated_json" | jq -r '.casks // [] | .[] | "    \(.name)  \(.installed_versions[0]) → \(.current_version)"' 2>/dev/null
            set total_outdated (math $total_outdated + $outdated_count)
        else
            echo "  "(set_color green)"✓ all up to date"(set_color normal)
        end
    else
        echo "  "(set_color yellow)"⚠ Homebrew not found, skipping"(set_color normal)
    end
    echo ""

    # ── pnpm -g ───────────────────────────────────────
    echo (set_color cyan --bold)"  pnpm -g"(set_color normal)
    if command -q pnpm
        set -l all_pkgs
        set -l all_vers
        for line in (pnpm list -g --depth 0 2>/dev/null)
            set -l parsed (string match -r '[├└]── (.+)@(.+)' $line)
            if test (count $parsed) -ge 3
                set -a all_pkgs $parsed[2]
                set -a all_vers $parsed[3]
            end
        end

        set -l outdated_names
        set -l outdated_current
        set -l outdated_latest
        for line in (pnpm outdated -g 2>/dev/null | tail -n +2)
            set -l parts (string match -r '(\S+)\s+(\S+)\s+\S+\s+(\S+)' $line 2>/dev/null)
            if test (count $parts) -ge 4
                set -a outdated_names $parts[2]
                set -a outdated_current $parts[3]
                set -a outdated_latest $parts[4]
            end
        end
        set -l pnpm_outdated (count $outdated_names)

        if test $pnpm_outdated -gt 0
            echo "  ($pnpm_outdated outdated)"
            set total_outdated (math $total_outdated + $pnpm_outdated)
        end

        set -l i 1
        for pkg in $all_pkgs
            set -l ver $all_vers[$i]
            set -l is_outdated false
            set -l j 1
            for oname in $outdated_names
                if test "$oname" = "$pkg"
                    echo "    $pkg  $outdated_current[$j] → $outdated_latest[$j]"
                    set is_outdated true
                    break
                end
                set j (math $j + 1)
            end
            if test "$is_outdated" = false
                echo "    $pkg  "(set_color green)"$ver ✓"(set_color normal)
            end
            set i (math $i + 1)
        end
    else
        echo "  "(set_color yellow)"⚠ pnpm not found, skipping"(set_color normal)
    end
    echo ""

    # ── uv tool ───────────────────────────────────────
    echo (set_color cyan --bold)"  uv tool"(set_color normal)

    if command -q uv
        # Classify tools: PyPI vs Git
        set -l pypi_names
        set -l pypi_vers
        set -l git_names
        set -l git_vers
        set -l git_urls

        for line in (uv tool list --show-version-specifiers 2>/dev/null)
            set -l git_match (string match -r -- '^(\S+)\s+v(\S+)\s+\[required:\s+git\+(.+)\]$' $line 2>/dev/null)
            if test (count $git_match) -ge 4
                set -a git_names $git_match[2]
                set -a git_vers $git_match[3]
                set -l git_url (string replace -r '@\S+$' '' $git_match[4])
                set -a git_urls $git_url
                continue
            end
            set -l pypi_match (string match -r -- '^(\S+)\s+v(\S+)$' $line 2>/dev/null)
            if test (count $pypi_match) -ge 3
                set -a pypi_names $pypi_match[2]
                set -a pypi_vers $pypi_match[3]
            end
        end

        # Collect all tools in display order (pypi first, then git)
        set -l all_names $pypi_names $git_names
        set -l all_vers $pypi_vers $git_vers
        set -l total_uv (count $all_names)

        # Build outdated map for PyPI tools (from uv tool list --outdated, excluding git tools)
        set -l outdated_map_names
        set -l outdated_map_info
        for line in (uv tool list --outdated 2>/dev/null)
            set -l match (string match -r -- '^(\S+)\s+v(\S+)\s+\[latest:\s+(\S+)\]$' $line 2>/dev/null)
            if test (count $match) -ge 4
                set -l is_git false
                for gn in $git_names
                    if test "$gn" = "$match[2]"
                        set is_git true
                        break
                    end
                end
                if test "$is_git" = false
                    set -a outdated_map_names $match[2]
                    set -a outdated_map_info "$match[3] → $match[4]"
                end
            end
        end

        # Check git tools via GitHub Releases API
        set -l git_outdated_map_names
        set -l git_outdated_map_info
        for i in (seq (count $git_names))
            set -l name $git_names[$i]
            set -l ver $git_vers[$i]
            set -l url $git_urls[$i]

            set -l repo_match (string match -r -- 'https://github.com/([^/]+)/([^/]+?)(?:\.git)?$' $url 2>/dev/null)
            if test (count $repo_match) -ge 3
                set -l owner $repo_match[2]
                set -l repo $repo_match[3]
                set -l release (curl -s "https://api.github.com/repos/$owner/$repo/releases/latest" 2>/dev/null)
                set -l latest_tag (echo "$release" | jq -r '.tag_name // empty' 2>/dev/null)
                set -l published (echo "$release" | jq -r '.published_at // empty' 2>/dev/null)

                if test -n "$latest_tag"
                    set -l latest_ver (string replace -r '^v' '' $latest_tag)
                    set -l current_ver (string replace -r '^v' '' $ver)
                    if test "$current_ver" != "$latest_ver"; and test -n "$latest_ver"
                        set -l date (string replace -r 'T.*' '' $published 2>/dev/null)
                        set -a git_outdated_map_names $name
                        set -a git_outdated_map_info "v$ver → $latest_tag ($date)"
                    end
                end
            end
        end

        # Count total outdated
        set -l uv_outdated (math (count $outdated_map_names) + (count $git_outdated_map_names))
        if test $uv_outdated -gt 0
            echo "  ($uv_outdated outdated)"
            set total_outdated (math $total_outdated + $uv_outdated)
        end

        # Display all tools (PyPI + Git, interleaved)
        for i in (seq $total_uv)
            set -l name $all_names[$i]
            set -l ver $all_vers[$i]
            set -l is_outdated false

            # Check PyPI outdated map
            set -l j 1
            for oname in $outdated_map_names
                if test "$oname" = "$name"
                    echo "    $name  $outdated_map_info[$j]"
                    set is_outdated true
                    break
                end
                set j (math $j + 1)
            end

            # Check Git outdated map
            if test "$is_outdated" = false
                set -l j 1
                for gname in $git_outdated_map_names
                    if test "$gname" = "$name"
                        echo "    $name  $git_outdated_map_info[$j]"
                        set is_outdated true
                        break
                    end
                    set j (math $j + 1)
                end
            end

            if test "$is_outdated" = false
                echo "    $name  "(set_color green)"$ver ✓"(set_color normal)
            end
        end
    else
        echo "  "(set_color yellow)"⚠ uv not found, skipping"(set_color normal)
    end
    echo ""

    # ── Summary ───────────────────────────────────────
    if test $total_outdated -gt 0
        echo "  $total_outdated packages can be updated. Run "(set_color --bold)"devflow upgrade"(set_color normal)" to update."
    else
        echo "  "(set_color green)"✓ All packages up to date"(set_color normal)
    end
    echo ""
end
