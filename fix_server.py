with open('lua/fk_markdown/preview/server.lua', 'r') as f:
    content = f.read()

content = content.replace("else\n                    \n                else\n                    -- attempt to serve local file", "else\n                    -- attempt to serve local file")

with open('lua/fk_markdown/preview/server.lua', 'w') as f:
    f.write(content)
