#!/usr/bin/env python3
"""
Post-process Structurizr Site Generatr output to use external SVG files
instead of inline SVGs. This allows using manually laid out diagrams.

Usage:
    python3 postprocess-build.py [build_dir] [diagrams_dir]

Defaults:
    build_dir: ./build
    diagrams_dir: ./diagrams
"""

import os
import re
import sys
from pathlib import Path


def fix_svg_dark_theme(svg_content: str) -> str:
    """Convert dark theme SVG to light theme."""
    # Change background from dark to white
    svg_content = re.sub(
        r'style="background:\s*#111111"',
        'style="background: #ffffff"',
        svg_content
    )

    # Change label background rectangles from dark to white
    svg_content = re.sub(
        r'fill="#111111"',
        'fill="#ffffff"',
        svg_content
    )

    # Change light gray text to black (for labels on arrows)
    svg_content = re.sub(
        r'fill="#cccccc"',
        'fill="#000000"',
        svg_content
    )

    # Change light gray strokes to dark gray (for arrows/lines)
    svg_content = re.sub(
        r'stroke="#cccccc"',
        'stroke="#707070"',
        svg_content
    )

    return svg_content


def get_svg_path_for_html(html_file: Path, svg_dir: Path, diagram_id: str) -> str:
    """Calculate relative path from HTML file to SVG file."""
    html_dir = html_file.parent
    svg_file = svg_dir / f"{diagram_id}.svg"
    return os.path.relpath(svg_file, html_dir)


def replace_inline_svgs(html_content: str, html_file: Path, svg_dir: Path) -> str:
    """Replace inline SVGs with object tags referencing external files."""

    # Pattern to match figure with inline SVG
    # <figure style="..." id="DIAGRAM-ID">
    #   <div><svg ...>...</svg></div>
    figure_pattern = re.compile(
        r'(<figure[^>]*id="([^"]+)"[^>]*>)\s*'
        r'<div><svg[^>]*>.*?</svg></div>',
        re.DOTALL
    )

    def replace_figure_svg(match):
        figure_tag = match.group(1)
        diagram_id = match.group(2)
        svg_path = get_svg_path_for_html(html_file, svg_dir, diagram_id)

        # Use object tag for better SVG support (clickable links, etc.)
        return (
            f'{figure_tag}\n'
            f'            <div><object type="image/svg+xml" data="{svg_path}" '
            f'style="width: 100%; height: auto;"></object></div>'
        )

    html_content = figure_pattern.sub(replace_figure_svg, html_content)

    # Pattern to match modal SVG
    # <div id="DIAGRAM-ID-svg" class="modal-box-content"><svg ...>...</svg></div>
    modal_pattern = re.compile(
        r'<div id="([^"]+)-svg" class="modal-box-content"><svg[^>]*>.*?</svg></div>',
        re.DOTALL
    )

    def replace_modal_svg(match):
        diagram_id = match.group(1)
        svg_path = get_svg_path_for_html(html_file, svg_dir, diagram_id)

        return (
            f'<div id="{diagram_id}-svg" class="modal-box-content">'
            f'<object type="image/svg+xml" data="{svg_path}" '
            f'style="width: 100%; height: auto;"></object></div>'
        )

    html_content = modal_pattern.sub(replace_modal_svg, html_content)

    return html_content


def process_build(build_dir: Path, diagrams_dir: Path):
    """Process all HTML files in build directory."""

    # SVG files are in build/master/svg/
    svg_dir = build_dir / "master" / "svg"

    if not svg_dir.exists():
        print(f"Error: SVG directory not found: {svg_dir}")
        sys.exit(1)

    # Copy manual layout SVGs if diagrams_dir is provided
    if diagrams_dir.exists():
        print(f"Copying manual layout SVGs from {diagrams_dir}...")
        for svg_file in diagrams_dir.glob("structurizr-1-*.svg"):
            # Extract diagram name: structurizr-1-C1-Context.svg -> C1-Context.svg
            name = svg_file.name.replace("structurizr-1-", "")
            dest = svg_dir / name

            # Read, fix dark theme, and write
            svg_content = svg_file.read_text(encoding="utf-8")
            svg_content = fix_svg_dark_theme(svg_content)
            dest.write_text(svg_content, encoding="utf-8")
            print(f"  Copied and fixed: {name}")

    # Find and process all HTML files
    html_files = list(build_dir.rglob("*.html"))
    print(f"\nProcessing {len(html_files)} HTML files...")

    modified_count = 0
    for html_file in html_files:
        content = html_file.read_text(encoding="utf-8")

        # Check if file contains inline SVGs in figures
        if '<figure' in content and '<svg' in content:
            new_content = replace_inline_svgs(content, html_file, svg_dir)

            if new_content != content:
                html_file.write_text(new_content, encoding="utf-8")
                print(f"  Modified: {html_file.relative_to(build_dir)}")
                modified_count += 1

    print(f"\nDone! Modified {modified_count} files.")


def main():
    # Default paths
    script_dir = Path(__file__).parent
    build_dir = Path(sys.argv[1]) if len(sys.argv) > 1 else script_dir / "build"
    diagrams_dir = Path(sys.argv[2]) if len(sys.argv) > 2 else script_dir / "diagrams"

    if not build_dir.exists():
        print(f"Error: Build directory not found: {build_dir}")
        sys.exit(1)

    print(f"Build directory: {build_dir}")
    print(f"Diagrams directory: {diagrams_dir}")

    process_build(build_dir, diagrams_dir)


if __name__ == "__main__":
    main()
