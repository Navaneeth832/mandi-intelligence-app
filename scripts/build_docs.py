#!/usr/bin/env python3
"""
Documentation Website Generator for Mandi Intelligence Project
===============================================================
Source of Truth: agent_helper.md
Output: docs/index.html

This script deterministically converts agent_helper.md into a modern,
responsive, search-enabled technical documentation website with rendered
Mermaid diagrams, syntax-highlighted code blocks, responsive tables,
light/dark theme toggle, and hierarchical sidebar navigation.
"""

import os
import re
import sys
import html
import subprocess
import markdown

# Paths
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SOURCE_MD = os.path.join(PROJECT_ROOT, "agent_helper.md")
DOCS_DIR = os.path.join(PROJECT_ROOT, "docs")
OUTPUT_HTML = os.path.join(DOCS_DIR, "index.html")


def get_git_repo_url():
    """Attempt to detect git remote origin URL safely."""
    try:
        url = subprocess.check_output(
            ["git", "config", "--get", "remote.origin.url"],
            cwd=PROJECT_ROOT,
            text=True
        ).strip()
        if url.startswith("git@github.com:"):
            url = "https://github.com/" + url[len("git@github.com:"):]
        if url.endswith(".git"):
            url = url[:-4]
        return url
    except Exception:
        return "https://github.com/Navaneeth832/mandi-intelligence-app"


def slugify(text):
    """Convert text into a URL-friendly anchor ID."""
    clean = re.sub(r'[^\w\s-]', '', text.lower())
    slug = re.sub(r'[\s_]+', '-', clean).strip('-')
    return slug or "section"


def extract_mermaid_blocks(md_text):
    """
    Extract mermaid code blocks and replace them with placeholder tokens
    to prevent markdown parser from modifying mermaid diagram syntax.
    """
    mermaid_blocks = []
    
    def replacer(match):
        content = match.group(1).strip()
        index = len(mermaid_blocks)
        mermaid_blocks.append(content)
        return f"\n\n:::MERMAID_BLOCK_{index}:::\n\n"

    # Match ```mermaid ... ```
    pattern = r"```mermaid\s*\n(.*?)\n```"
    processed_md = re.sub(pattern, replacer, md_text, flags=re.DOTALL)
    return processed_md, mermaid_blocks


def build_sidebar_and_headings(md_text):
    """Parse headings from markdown to construct hierarchical navigation structure."""
    headings = []
    lines = md_text.splitlines()
    in_code_block = False
    
    for line in lines:
        if line.strip().startswith("```"):
            in_code_block = not in_code_block
            continue
        if in_code_block:
            continue
            
        m = re.match(r'^(#{1,4})\s+(.+)$', line.strip())
        if m:
            level = len(m.group(1))
            title_text = m.group(2).strip()
            # Strip markdown inline links or formatting for title text
            clean_title = re.sub(r'\[([^\]]+)\]\([^)]+\)', r'\1', title_text)
            clean_title = re.sub(r'[*`_]', '', clean_title)
            anchor = slugify(clean_title)
            
            headings.append({
                "level": level,
                "title": clean_title,
                "anchor": anchor,
                "raw": title_text
            })
            
    return headings


def add_anchors_to_html(rendered_html, headings):
    """Ensure HTML headings have corresponding id attributes for deep linking."""
    heading_counter = {}
    
    def replace_heading(match):
        tag = match.group(1)
        content = match.group(2)
        clean_text = re.sub(r'<[^>]+>', '', content).strip()
        slug = slugify(clean_text)
        
        # Handle duplicate slugs
        if slug in heading_counter:
            heading_counter[slug] += 1
            unique_slug = f"{slug}-{heading_counter[slug]}"
        else:
            heading_counter[slug] = 1
            unique_slug = slug
            
        return f'<{tag} id="{unique_slug}" class="doc-heading">{content}</{tag}>'

    pattern = r'<(h[1-4])>(.*?)</\1>'
    return re.sub(pattern, replace_heading, rendered_html, flags=re.DOTALL)


def generate_site():
    if not os.path.exists(SOURCE_MD):
        print(f"Error: Source file {SOURCE_MD} does not exist.")
        sys.exit(1)

    with open(SOURCE_MD, "r", encoding="utf-8") as f:
        raw_md = f.read()

    print(f"Reading {SOURCE_MD} ({len(raw_md)} bytes)...")

    # 1. Preprocess Mermaid diagrams
    processed_md, mermaid_blocks = extract_mermaid_blocks(raw_md)
    print(f"Detected {len(mermaid_blocks)} Mermaid diagram(s).")

    # 2. Extract Headings for Navigation
    headings = build_sidebar_and_headings(raw_md)
    print(f"Extracted {len(headings)} section heading(s).")

    # 3. Convert Markdown to HTML
    md_parser = markdown.Markdown(
        extensions=[
            "tables",
            "fenced_code",
            "toc",
            "attr_list",
            "def_list",
            "sane_lists",
            "nl2br"
        ]
    )
    raw_html = md_parser.convert(processed_md)

    # 4. Inject Anchors to Headings
    html_with_anchors = add_anchors_to_html(raw_html, headings)

    # 5. Restore Mermaid diagrams as HTML components with high-resolution controls
    for i, diagram_code in enumerate(mermaid_blocks):
        escaped_code = html.escape(diagram_code)
        mermaid_html = f'''
<div class="mermaid-card">
    <div class="mermaid-card-header">
        <span class="mermaid-card-title">📊 Architecture Diagram</span>
        <div class="mermaid-card-controls">
            <button class="mermaid-expand-btn" onclick="zoomMermaid(this, 0.2)" title="Zoom In">🔍 +</button>
            <button class="mermaid-expand-btn" onclick="zoomMermaid(this, -0.2)" title="Zoom Out">🔍 −</button>
            <button class="mermaid-expand-btn" onclick="resetMermaidZoom(this)" title="Reset Zoom">↺ Reset</button>
            <button class="mermaid-expand-btn" onclick="toggleMermaidFullscreen(this)" title="Toggle Fullscreen">⤢ Fullscreen</button>
        </div>
    </div>
    <div class="mermaid-viewport">
        <div class="mermaid-scale-wrapper">
            <pre class="mermaid">{escaped_code}</pre>
        </div>
    </div>
</div>
'''
        placeholder = f"<p>:::MERMAID_BLOCK_{i}:::</p>"
        if placeholder not in html_with_anchors:
            placeholder = f":::MERMAID_BLOCK_{i}:::"
        html_with_anchors = html_with_anchors.replace(placeholder, mermaid_html)

    # Detect GitHub repo URL
    repo_url = get_git_repo_url()

    # 6. Build Navigation HTML
    nav_html_items = []
    for h in headings:
        level_class = f"nav-level-{h['level']}"
        nav_html_items.append(
            f'<a class="nav-item {level_class}" href="#{h["anchor"]}" onclick="closeMobileNav()">{html.escape(h["title"])}</a>'
        )
    nav_html = "\n".join(nav_html_items)

    # 7. Construct Full HTML Document Template
    full_html = f'''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mandi Intelligence - Technical Documentation</title>
    <meta name="description" content="Complete technical documentation, architecture, database schemas, APIs, and machine learning pipeline for Mandi Intelligence Project.">
    
    <!-- Google Fonts -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600&display=swap" rel="stylesheet">
    
    <!-- Mermaid.js for Rendering Diagrams -->
    <script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>

    <style>
        :root {{
            --font-main: 'Plus Jakarta Sans', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
            --font-code: 'JetBrains Mono', monospace;
            
            --bg-body: #F8FAFC;
            --bg-card: #FFFFFF;
            --bg-sidebar: #FFFFFF;
            --bg-header: rgba(255, 255, 255, 0.85);
            --bg-code: #0F172A;
            --text-code: #F8FAFC;
            
            --text-primary: #0F172A;
            --text-secondary: #475569;
            --text-muted: #94A3B8;
            
            --brand-green: #27A32D;
            --brand-green-light: #F0FDF4;
            --brand-green-border: #DCFCE7;
            
            --border-color: #E2E8F0;
            --border-subtle: #F1F5F9;
            
            --sidebar-width: 290px;
            --header-height: 64px;
            --radius-sm: 8px;
            --radius-md: 12px;
            --radius-lg: 18px;
            
            --shadow-sm: 0 1px 3px rgba(15, 23, 42, 0.05);
            --shadow-md: 0 4px 12px rgba(15, 23, 42, 0.08);
            --shadow-lg: 0 12px 24px rgba(15, 23, 42, 0.12);
        }}

        [data-theme="dark"] {{
            --bg-body: #090D16;
            --bg-card: #111827;
            --bg-sidebar: #0F172A;
            --bg-header: rgba(15, 23, 42, 0.85);
            --bg-code: #030712;
            --text-code: #E2E8F0;
            
            --text-primary: #F8FAFC;
            --text-secondary: #94A3B8;
            --text-muted: #64748B;
            
            --brand-green: #4ADE80;
            --brand-green-light: rgba(39, 163, 45, 0.15);
            --brand-green-border: rgba(39, 163, 45, 0.3);
            
            --border-color: #1E293B;
            --border-subtle: #0F172A;
            
            --shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.3);
            --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.4);
            --shadow-lg: 0 12px 24px rgba(0, 0, 0, 0.6);
        }}

        * {{
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }}

        html {{
            scroll-behavior: smooth;
            font-family: var(--font-main);
            background-color: var(--bg-body);
            color: var(--text-primary);
        }}

        body {{
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            line-height: 1.6;
        }}

        /* Header */
        header {{
            position: sticky;
            top: 0;
            z-index: 50;
            height: var(--header-height);
            background-color: var(--bg-header);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border-bottom: 1px solid var(--border-color);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 24px;
        }}

        .brand-container {{
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            color: var(--text-primary);
        }}

        .brand-logo {{
            width: 36px;
            height: 36px;
            background: linear-gradient(135deg, #27A32D, #15803D);
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 20px;
            box-shadow: 0 2px 8px rgba(39, 163, 45, 0.3);
        }}

        .brand-title {{
            font-size: 17px;
            font-weight: 800;
            letter-spacing: -0.3px;
        }}

        .brand-badge {{
            font-size: 11px;
            font-weight: 700;
            background-color: var(--brand-green-light);
            color: var(--brand-green);
            border: 1px solid var(--brand-green-border);
            padding: 2px 8px;
            border-radius: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }}

        .header-actions {{
            display: flex;
            align-items: center;
            gap: 14px;
        }}

        .search-box {{
            position: relative;
            width: 260px;
        }}

        .search-box input {{
            width: 100%;
            padding: 8px 14px 8px 36px;
            background-color: var(--bg-body);
            border: 1px solid var(--border-color);
            border-radius: 20px;
            font-size: 13px;
            color: var(--text-primary);
            outline: none;
            transition: all 0.2s ease;
        }}

        .search-box input:focus {{
            border-color: var(--brand-green);
            box-shadow: 0 0 0 3px var(--brand-green-light);
        }}

        .search-icon {{
            position: absolute;
            left: 12px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--text-muted);
            font-size: 14px;
            pointer-events: none;
        }}

        .icon-btn {{
            background: none;
            border: 1px solid var(--border-color);
            border-radius: 10px;
            padding: 8px 12px;
            color: var(--text-secondary);
            font-size: 14px;
            font-weight: 600;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 6px;
            transition: all 0.2s ease;
            text-decoration: none;
        }}

        .icon-btn:hover {{
            background-color: var(--bg-body);
            color: var(--brand-green);
            border-color: var(--brand-green-border);
        }}

        .mobile-menu-btn {{
            display: none;
        }}

        /* Main Layout */
        .layout-container {{
            display: flex;
            flex: 1;
            max-width: 1536px;
            width: 100%;
            margin: 0 auto;
        }}

        /* Sidebar */
        aside {{
            width: var(--sidebar-width);
            background-color: var(--bg-sidebar);
            border-right: 1px solid var(--border-color);
            position: sticky;
            top: var(--header-height);
            height: calc(100vh - var(--header-height));
            overflow-y: auto;
            padding: 24px 16px;
            flex-shrink: 0;
        }}

        .sidebar-heading {{
            font-size: 11px;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: 0.8px;
            color: var(--text-muted);
            margin-bottom: 12px;
            padding-left: 10px;
        }}

        .nav-list {{
            display: flex;
            flex-direction: column;
            gap: 2px;
        }}

        .nav-item {{
            display: block;
            padding: 7px 12px;
            border-radius: var(--radius-sm);
            text-decoration: none;
            color: var(--text-secondary);
            font-size: 13px;
            font-weight: 500;
            transition: all 0.15s ease;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }}

        .nav-item:hover {{
            background-color: var(--brand-green-light);
            color: var(--brand-green);
        }}

        .nav-item.active {{
            background-color: var(--brand-green-light);
            color: var(--brand-green);
            font-weight: 700;
            border-left: 3px solid var(--brand-green);
        }}

        .nav-level-1 {{ font-weight: 700; color: var(--text-primary); margin-top: 10px; }}
        .nav-level-2 {{ padding-left: 16px; }}
        .nav-level-3 {{ padding-left: 28px; font-size: 12.5px; opacity: 0.85; }}
        .nav-level-4 {{ padding-left: 38px; font-size: 12px; opacity: 0.75; }}

        /* Main Content */
        main {{
            flex: 1;
            padding: 40px 48px 80px 48px;
            max-width: 1080px;
            overflow-x: hidden;
        }}

        /* Content Styling */
        .markdown-body {{
            color: var(--text-primary);
        }}

        .markdown-body h1 {{
            font-size: 32px;
            font-weight: 800;
            letter-spacing: -0.8px;
            margin-bottom: 16px;
            padding-bottom: 12px;
            border-bottom: 2px solid var(--border-color);
            color: var(--text-primary);
            scroll-margin-top: calc(var(--header-height) + 24px);
        }}

        .markdown-body h2 {{
            font-size: 22px;
            font-weight: 800;
            letter-spacing: -0.4px;
            margin-top: 40px;
            margin-bottom: 16px;
            padding-bottom: 8px;
            border-bottom: 1px solid var(--border-color);
            color: var(--text-primary);
            scroll-margin-top: calc(var(--header-height) + 24px);
        }}

        .markdown-body h3 {{
            font-size: 17px;
            font-weight: 700;
            margin-top: 28px;
            margin-bottom: 12px;
            color: var(--text-primary);
            scroll-margin-top: calc(var(--header-height) + 24px);
        }}

        .markdown-body p {{
            margin-bottom: 16px;
            color: var(--text-secondary);
            font-size: 15px;
            line-height: 1.7;
        }}

        .markdown-body ul, .markdown-body ol {{
            margin-bottom: 18px;
            padding-left: 24px;
            color: var(--text-secondary);
            font-size: 14.5px;
        }}

        .markdown-body li {{
            margin-bottom: 6px;
            line-height: 1.6;
        }}

        .markdown-body hr {{
            border: 0;
            height: 1px;
            background-color: var(--border-color);
            margin: 36px 0;
        }}

        .markdown-body blockquote {{
            border-left: 4px solid var(--brand-green);
            background-color: var(--brand-green-light);
            padding: 14px 20px;
            border-radius: 0 var(--radius-md) var(--radius-md) 0;
            margin-bottom: 20px;
            color: var(--text-secondary);
            font-style: italic;
        }}

        /* Inline Code & Code Blocks */
        code {{
            font-family: var(--font-code);
            font-size: 13.5px;
            background-color: var(--border-subtle);
            color: var(--brand-green);
            padding: 2px 6px;
            border-radius: 5px;
            border: 1px solid var(--border-color);
        }}

        pre {{
            background-color: var(--bg-code);
            color: var(--text-code);
            padding: 20px;
            border-radius: var(--radius-md);
            overflow-x: auto;
            margin-bottom: 24px;
            box-shadow: var(--shadow-sm);
            border: 1px solid var(--border-color);
        }}

        pre code {{
            background: none;
            color: inherit;
            padding: 0;
            border: none;
            font-size: 13px;
            line-height: 1.6;
        }}

        /* Responsive Tables */
        .table-wrapper {{
            width: 100%;
            overflow-x: auto;
            margin-bottom: 28px;
            border-radius: var(--radius-md);
            border: 1px solid var(--border-color);
            box-shadow: var(--shadow-sm);
            background-color: var(--bg-card);
        }}

        table {{
            width: 100%;
            border-collapse: collapse;
            font-size: 13.5px;
            text-align: left;
        }}

        th {{
            background-color: var(--border-subtle);
            color: var(--text-primary);
            font-weight: 700;
            padding: 12px 16px;
            border-bottom: 1px solid var(--border-color);
            white-space: nowrap;
        }}

        td {{
            padding: 12px 16px;
            border-bottom: 1px solid var(--border-subtle);
            color: var(--text-secondary);
        }}

        tr:last-child td {{
            border-bottom: none;
        }}

        tr:hover td {{
            background-color: var(--brand-green-light);
        }}

        /* High-Resolution Mermaid Cards & Sizing */
        .mermaid-card {{
            background-color: var(--bg-card);
            border: 1px solid var(--border-color);
            border-radius: var(--radius-lg);
            margin: 32px 0;
            box-shadow: var(--shadow-md);
            overflow: hidden;
            transition: all 0.25s ease;
        }}

        .mermaid-card.expanded {{
            position: fixed;
            inset: 20px;
            z-index: 1000;
            margin: 0;
            border-radius: var(--radius-lg);
            box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.7);
            display: flex;
            flex-direction: column;
            background-color: var(--bg-card);
        }}

        .mermaid-card-header {{
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 14px 24px;
            background-color: var(--border-subtle);
            border-bottom: 1px solid var(--border-color);
        }}

        .mermaid-card-title {{
            font-size: 14px;
            font-weight: 700;
            color: var(--text-primary);
            display: flex;
            align-items: center;
            gap: 8px;
        }}

        .mermaid-card-controls {{
            display: flex;
            align-items: center;
            gap: 8px;
        }}

        .mermaid-expand-btn {{
            background: var(--bg-card);
            border: 1px solid var(--border-color);
            padding: 6px 12px;
            border-radius: 8px;
            font-size: 12px;
            font-weight: 700;
            color: var(--text-primary);
            cursor: pointer;
            transition: all 0.2s ease;
        }}

        .mermaid-expand-btn:hover {{
            background-color: var(--brand-green-light);
            color: var(--brand-green);
            border-color: var(--brand-green-border);
        }}

        .mermaid-viewport {{
            padding: 32px;
            overflow: auto;
            display: flex;
            justify-content: center;
            align-items: flex-start;
            background-color: var(--bg-card);
            min-height: 420px;
            max-height: 650px;
        }}

        .mermaid-card.expanded .mermaid-viewport {{
            max-height: none;
            flex: 1;
        }}

        .mermaid-scale-wrapper {{
            display: inline-block;
            transition: transform 0.2s ease;
            transform-origin: top center;
            width: 100%;
        }}

        .mermaid {{
            font-family: var(--font-main) !important;
            display: flex;
            justify-content: center;
            width: 100%;
        }}

        /* Force crisp large SVG rendering */
        .mermaid svg {{
            max-width: none !important;
            min-width: 950px !important;
            height: auto !important;
            font-size: 15px !important;
        }}

        .mermaid-card.expanded .mermaid svg {{
            min-width: 1300px !important;
        }}

        /* Footer */
        footer {{
            border-top: 1px solid var(--border-color);
            padding: 24px 48px;
            text-align: center;
            font-size: 13px;
            color: var(--text-muted);
            background-color: var(--bg-card);
            margin-top: auto;
        }}

        /* Mobile Drawer & Overlay */
        .mobile-overlay {{
            display: none;
            position: fixed;
            inset: 0;
            background-color: rgba(15, 23, 42, 0.5);
            backdrop-filter: blur(4px);
            z-index: 40;
        }}

        /* Media Queries */
        @media (max-width: 1024px) {{
            aside {{
                position: fixed;
                left: -100%;
                top: var(--header-height);
                height: calc(100vh - var(--header-height));
                z-index: 45;
                transition: left 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                box-shadow: var(--shadow-lg);
            }}

            aside.open {{
                left: 0;
            }}

            .mobile-overlay.open {{
                display: block;
            }}

            .mobile-menu-btn {{
                display: flex;
            }}

            main {{
                padding: 28px 24px 60px 24px;
            }}
        }}

        @media (max-width: 640px) {{
            .search-box {{
                display: none;
            }}

            header {{
                padding: 0 16px;
            }}

            .brand-badge {{
                display: none;
            }}
        }}
    </style>
</head>
<body>

    <!-- Header -->
    <header>
        <div style="display: flex; align-items: center; gap: 12px;">
            <button class="icon-btn mobile-menu-btn" onclick="toggleMobileNav()" aria-label="Toggle Menu">
                ☰
            </button>
            <a href="#" class="brand-container">
                <div class="brand-logo">🚜</div>
                <span class="brand-title">Mandi Intelligence</span>
                <span class="brand-badge">Docs</span>
            </a>
        </div>

        <div class="header-actions">
            <div class="search-box">
                <span class="search-icon">🔍</span>
                <input type="text" id="docSearchInput" placeholder="Search documentation..." onkeyup="filterDocsSearch()">
            </div>

            <button class="icon-btn" onclick="toggleTheme()" title="Toggle Theme">
                <span id="themeIcon">🌙</span>
            </button>

            <a href="{repo_url}" target="_blank" rel="noopener noreferrer" class="icon-btn">
                <svg height="18" width="18" viewBox="0 0 16 16" fill="currentColor">
                    <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.28.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z"/>
                </svg>
                <span>GitHub</span>
            </a>
        </div>
    </header>

    <!-- Mobile Nav Overlay -->
    <div class="mobile-overlay" id="mobileOverlay" onclick="closeMobileNav()"></div>

    <!-- Main Container -->
    <div class="layout-container">
        
        <!-- Sidebar -->
        <aside id="sidebar">
            <div class="sidebar-heading">Documentation Map</div>
            <nav class="nav-list">
                {nav_html}
            </nav>
        </aside>

        <!-- Main Content -->
        <main>
            <article class="markdown-body" id="docsContent">
                {html_with_anchors}
            </article>
        </main>
    </div>

    <!-- Footer -->
    <footer>
        <p>Mandi Intelligence Project Documentation • Generated automatically from <code>agent_helper.md</code></p>
    </footer>

    <!-- Interactive Scripts -->
    <script>
        // 1. Mermaid Initialization with High-Resolution Rendering
        document.addEventListener("DOMContentLoaded", function() {{
            mermaid.initialize({{
                startOnLoad: true,
                theme: document.documentElement.getAttribute('data-theme') === 'dark' ? 'dark' : 'default',
                securityLevel: 'loose',
                flowchart: {{ useMaxWidth: false, htmlLabels: true, curve: 'basis' }},
                er: {{ useMaxWidth: false }},
                sequence: {{ useMaxWidth: false }}
            }});

            // Wrap tables in responsive wrapper
            document.querySelectorAll('.markdown-body table').forEach(function(table) {{
                var wrapper = document.createElement('div');
                wrapper.className = 'table-wrapper';
                table.parentNode.insertBefore(wrapper, table);
                wrapper.appendChild(table);
            }});

            // Active nav highlight on scroll
            initScrollSpy();
        }});

        // 2. Theme Toggle (Light/Dark)
        function toggleTheme() {{
            const currentTheme = document.documentElement.getAttribute('data-theme');
            const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
            document.documentElement.setAttribute('data-theme', newTheme);
            localStorage.setItem('theme', newTheme);
            document.getElementById('themeIcon').textContent = newTheme === 'dark' ? '☀️' : '🌙';
            
            location.reload();
        }}

        // Restore Theme Preference
        (function() {{
            const savedTheme = localStorage.getItem('theme') || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
            document.documentElement.setAttribute('data-theme', savedTheme);
            document.addEventListener('DOMContentLoaded', () => {{
                document.getElementById('themeIcon').textContent = savedTheme === 'dark' ? '☀️' : '🌙';
            }});
        }})();

        // 3. Mobile Navigation Controls
        function toggleMobileNav() {{
            document.getElementById('sidebar').classList.toggle('open');
            document.getElementById('mobileOverlay').classList.toggle('open');
        }}

        function closeMobileNav() {{
            document.getElementById('sidebar').classList.remove('open');
            document.getElementById('mobileOverlay').classList.remove('open');
        }}

        // 4. Live Search Filter
        function filterDocsSearch() {{
            const input = document.getElementById('docSearchInput').value.toLowerCase();
            const content = document.getElementById('docsContent');
            const items = content.querySelectorAll('h1, h2, h3, p, li, tr');

            if (!input) {{
                items.forEach(el => el.style.display = '');
                return;
            }}

            items.forEach(el => {{
                const text = el.textContent.toLowerCase();
                if (text.includes(input)) {{
                    el.style.display = '';
                }} else {{
                    el.style.display = 'none';
                }}
            }});
        }}

        // 5. ScrollSpy Active Section Highlighting
        function initScrollSpy() {{
            const headings = Array.from(document.querySelectorAll('.doc-heading'));
            const navItems = Array.from(document.querySelectorAll('.nav-item'));

            window.addEventListener('scroll', function() {{
                let current = '';
                const scrollPos = window.scrollY + 100;

                headings.forEach(heading => {{
                    if (scrollPos >= heading.offsetTop) {{
                        current = heading.getAttribute('id');
                    }}
                }});

                navItems.forEach(item => {{
                    item.classList.remove('active');
                    if (item.getAttribute('href') === '#' + current) {{
                        item.classList.add('active');
                    }}
                }});
            }});
        }}

        // 6. Interactive Diagram Zoom Controls
        function zoomMermaid(btn, factor) {{
            const card = btn.closest('.mermaid-card');
            const wrapper = card.querySelector('.mermaid-scale-wrapper');
            if (!wrapper) return;
            
            let currentScale = parseFloat(wrapper.getAttribute('data-scale') || '1.0');
            currentScale = Math.max(0.6, Math.min(3.0, currentScale + factor));
            wrapper.setAttribute('data-scale', currentScale);
            wrapper.style.transform = `scale(${{currentScale}})`;
        }}

        function resetMermaidZoom(btn) {{
            const card = btn.closest('.mermaid-card');
            const wrapper = card.querySelector('.mermaid-scale-wrapper');
            if (!wrapper) return;
            wrapper.setAttribute('data-scale', '1.0');
            wrapper.style.transform = 'scale(1.0)';
        }}

        function toggleMermaidFullscreen(btn) {{
            const card = btn.closest('.mermaid-card');
            card.classList.toggle('expanded');
            if (card.classList.contains('expanded')) {{
                btn.textContent = '⤓ Close Fullscreen';
            }} else {{
                btn.textContent = '⤢ Fullscreen';
            }}
        }}
    </script>
</body>
</html>
'''

    os.makedirs(DOCS_DIR, exist_ok=True)
    with open(OUTPUT_HTML, "w", encoding="utf-8") as f:
        f.write(full_html)

    print(f"Successfully generated documentation site at {OUTPUT_HTML}")


if __name__ == "__main__":
    generate_site()
