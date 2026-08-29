local kitty = require('fk_markdown.latex.kitty')

-- Use the same test PNG
local path = "/Users/mayankjha/.cache/nvim/fk_markdown/latex/0a9da9bec9458bf2.png"
if vim.fn.filereadable(path) == 1 then
    local id = 999
    local encoded = vim.base64.encode(path)
    
    local stdout = vim.uv.new_tty(1, false)
    
    -- Command 1: Transmit file (t=f)
    stdout:write(string.format("\x1b_Ga=t,f=100,t=f,i=%d,q=2;%s\x1b\\", id, encoded))
    vim.uv.sleep(10)
    
    -- Command 2: Register placeholder
    stdout:write(string.format("\x1b_Ga=p,U=1,i=%d,r=2,c=10,q=2\x1b\\", id))
    
    print("Sent t=f test. Image should be registered.")
else
    print("File not found")
end
