import sys

for line in sys.stdin:
    num = int(line, 16)
    if num >= 1<<31:
        num -= 1<<32
    print(num / float(1 << 12))
