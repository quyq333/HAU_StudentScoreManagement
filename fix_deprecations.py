import os, re, sys

PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
LIB_DIR = os.path.join(PROJECT_ROOT, 'lib')

def fix_file(path):
    with open(path, 'r', encoding='utf-8') as f:
        content = f.read()
    original = content
    # Replace .withOpacity(
    content = re.sub(r'\.withOpacity\s*\(', '.withValues(', content)
    # Replace background: with surface:
    content = re.sub(r'background\s*:', 'surface:', content)
    # Remove .toList() after spread (simple replace)
    content = content.replace('.toList()', '')
    if content != original:
        with open(path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"Updated {path}")

for root, dirs, files in os.walk(LIB_DIR):
    for file in files:
        if file.endswith('.dart'):
            fix_file(os.path.join(root, file))
