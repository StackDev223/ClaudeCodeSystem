#!/usr/bin/env python3
"""
Convert Markdown to Google Doc

Converts a markdown file to styled HTML and uploads it to Google Drive as a
Google Doc. This avoids Google Docs API formatting issues by letting Google's
import converter handle the HTML-to-Doc conversion.

Usage:
  python3 md-to-gdoc.py <markdown_file> [--title "Doc Title"] [--folder-id ID] [--json]

Requires:
  pip3 install markdown requests

Credentials:
  Reads GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REFRESH_TOKEN from
  environment variables or from .env file at the vault root.
"""

import argparse
import json
import os
import re
import sys

import markdown
import requests


def load_env(env_path=None):
    """Load credentials from .env file if not already in environment."""
    if all(os.environ.get(k) for k in ['GOOGLE_CLIENT_ID', 'GOOGLE_CLIENT_SECRET', 'GOOGLE_REFRESH_TOKEN']):
        return

    if env_path is None:
        # Try .env in current directory
        env_path = os.path.join(os.getcwd(), '.env')

    if os.path.exists(env_path):
        with open(env_path) as f:
            for line in f:
                if '=' in line and not line.startswith('#'):
                    key, value = line.strip().split('=', 1)
                    os.environ[key] = value


def get_access_token():
    """Get fresh Google OAuth access token using refresh token."""
    client_id = os.environ.get('GOOGLE_CLIENT_ID')
    client_secret = os.environ.get('GOOGLE_CLIENT_SECRET')
    refresh_token = os.environ.get('GOOGLE_REFRESH_TOKEN')

    if not all([client_id, client_secret, refresh_token]):
        print("Error: Missing Google OAuth credentials. Set GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, and GOOGLE_REFRESH_TOKEN in .env or environment.", file=sys.stderr)
        sys.exit(1)

    response = requests.post(
        'https://oauth2.googleapis.com/token',
        data={
            'grant_type': 'refresh_token',
            'client_id': client_id,
            'client_secret': client_secret,
            'refresh_token': refresh_token
        }
    )

    if response.status_code != 200:
        print(f"Error: Failed to get access token: {response.status_code} {response.text}", file=sys.stderr)
        sys.exit(1)

    return response.json()['access_token']


def convert_md_to_html(md_content):
    """Convert markdown to styled HTML suitable for Google Docs import."""
    # Handle fenced code blocks -- convert to pre tags before markdown processing
    md_content = re.sub(
        r'```(?:sql|python|bash|javascript|json|[a-z]*)?\n(.*?)```',
        lambda m: f'<pre style="font-family: monospace; background: #f5f5f5; padding: 15px; border-radius: 5px; overflow-x: auto;">{m.group(1)}</pre>',
        md_content,
        flags=re.DOTALL
    )

    # Convert markdown to HTML with table support
    md = markdown.Markdown(extensions=['tables', 'fenced_code'])
    html_body = md.convert(md_content)

    # Wrap in full HTML with styling
    return f'''<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <style>
        body {{ font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; line-height: 1.6; }}
        h1 {{ color: #1a1a1a; border-bottom: 2px solid #333; padding-bottom: 10px; }}
        h2 {{ color: #333; margin-top: 30px; }}
        h3 {{ color: #444; }}
        h4 {{ color: #555; }}
        table {{ border-collapse: collapse; width: 100%; margin: 15px 0; }}
        th, td {{ border: 1px solid #ddd; padding: 10px; text-align: left; }}
        th {{ background-color: #f5f5f5; font-weight: bold; }}
        tr:nth-child(even) {{ background-color: #fafafa; }}
        blockquote {{ border-left: 4px solid #ccc; margin: 15px 0; padding: 10px 20px; background: #f9f9f9; font-style: italic; }}
        pre {{ background: #f5f5f5; padding: 15px; border-radius: 5px; overflow-x: auto; font-family: 'Courier New', monospace; font-size: 12px; white-space: pre-wrap; }}
        code {{ background: #f0f0f0; padding: 2px 6px; border-radius: 3px; font-family: 'Courier New', monospace; }}
        ul, ol {{ margin: 10px 0; padding-left: 25px; }}
        li {{ margin: 5px 0; }}
        hr {{ border: none; border-top: 2px solid #ddd; margin: 30px 0; }}
    </style>
</head>
<body>
{html_body}
</body>
</html>'''


def upload_to_drive(html_content, title, folder_id, access_token):
    """Upload HTML as a Google Doc via Drive API multipart upload."""
    boundary = '----FormBoundary7MA4YWxkTrZu0gW'

    metadata = {
        'name': title,
        'mimeType': 'application/vnd.google-apps.document'
    }
    if folder_id:
        metadata['parents'] = [folder_id]

    body = f'''--{boundary}\r\nContent-Type: application/json; charset=UTF-8\r\n\r\n{json.dumps(metadata)}\r\n--{boundary}\r\nContent-Type: text/html\r\n\r\n{html_content}\r\n--{boundary}--'''

    headers = {
        'Authorization': f'Bearer {access_token}',
        'Content-Type': f'multipart/related; boundary={boundary}'
    }

    response = requests.post(
        'https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart',
        headers=headers,
        data=body.encode('utf-8')
    )

    if response.status_code != 200:
        print(f"Error: Upload failed: {response.status_code} {response.text}", file=sys.stderr)
        sys.exit(1)

    return response.json()


def get_doc_link(doc_id, access_token):
    """Get the shareable link for a Google Doc."""
    response = requests.get(
        f'https://www.googleapis.com/drive/v3/files/{doc_id}?fields=webViewLink',
        headers={'Authorization': f'Bearer {access_token}'}
    )
    if response.status_code == 200:
        return response.json().get('webViewLink')
    return f'https://docs.google.com/document/d/{doc_id}/edit'


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('markdown_file', help='Path to the markdown file to convert')
    parser.add_argument('--title', help='Google Doc title (defaults to filename without extension)')
    parser.add_argument('--folder-id', help='Google Drive folder ID to upload into')
    parser.add_argument('--env', help='Path to .env file (defaults to .env in current directory)')
    parser.add_argument('--json', action='store_true', help='Output result as JSON')
    args = parser.parse_args()

    if not os.path.exists(args.markdown_file):
        print(f"Error: File not found: {args.markdown_file}", file=sys.stderr)
        sys.exit(1)

    # Load credentials
    load_env(args.env)

    # Read and convert markdown
    with open(args.markdown_file, 'r') as f:
        md_content = f.read()

    title = args.title or os.path.splitext(os.path.basename(args.markdown_file))[0]
    html_content = convert_md_to_html(md_content)

    # Upload
    access_token = get_access_token()
    result = upload_to_drive(html_content, title, args.folder_id, access_token)
    doc_id = result['id']
    link = get_doc_link(doc_id, access_token)

    if args.json:
        print(json.dumps({'id': doc_id, 'title': title, 'link': link}))
    else:
        print(f"Created: {title}")
        print(f"Link: {link}")


if __name__ == '__main__':
    main()
