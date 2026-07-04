Intended to be used with LuaJIT.

To use if you *really* want to,
1. Copy an entire bill PDF with Ctrl + A and Ctrl + C.
2. Run the code with `luajit main.lua`
3. Paste in all the text, each line should individually be entered automatically
4. If it errors, oh well. If it works, it'll say "Success!"
5. If it worked, look at `output.txt`

Generall only works if the contents of the bill looks like this, for example:
```
3 M.S.C. 1 § 41011 shall be amended to read: “Such officers are
authorized, while acting within the scope of official duties and
subject to the jurisdictional limits established by this Act, to:”
```
