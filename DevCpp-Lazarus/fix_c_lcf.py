import io

p = r'C:\Users\Administrator\WorkBuddy\2026-DevCpp-Lazarus\DevCpp-Lazarus\lexers\C.lcf'
data = io.open(p, encoding='utf-8').read()

bad = '#13#10'
good = r'\x0D\x0A'   # raw string, stays as backslash-x-0-D-x-0-A

print('count bad (before):', data.count(bad))
assert data.count(bad) >= 1, 'marker not found'
data = data.replace(bad, good)
print('count good (after):', data.count(good))
print('count bad (after):', data.count(bad))
io.open(p, 'w', encoding='utf-8').write(data)
print('done')
