import re

html_template = """
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>fk_markdown preview</title>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/github-markdown-css/5.2.0/github-markdown-dark.min.css">
<script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/dompurify/3.0.3/purify.min.js"></script>
<style>
body { font-family: sans-serif; padding: 20px; max-width: 900px; margin: auto; background-color: #0d1117; }
.markdown-body { box-sizing: border-box; min-width: 200px; max-width: 980px; margin: 0 auto; padding: 45px; }
@media (max-width: 767px) { .markdown-body { padding: 15px; } }
</style>
</head>
<body>
<article class="markdown-body" id="content"></article>
<script>
const contentDiv = document.getElementById('content');
const es = new EventSource('/events');
es.onmessage = function(e) {
    const md = JSON.parse(e.data);
    contentDiv.innerHTML = DOMPurify.sanitize(marked.parse(md));
};
</script>
</body>
</html>
"""

with open('lua/fk_markdown/preview/server.lua', 'r') as f:
    content = f.read()

content = re.sub(r'local html_template = \[\[.*?\]\]', 'local html_template = [[' + html_template + ']]', content, flags=re.DOTALL)

with open('lua/fk_markdown/preview/server.lua', 'w') as f:
    f.write(content)
