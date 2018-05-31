#coding:utf8

import re
import sys
import os

if len(sys.argv) == 2:
    logPath = sys.argv[1]
    if not os.path.exists(logPath):
        print "File " + logPath + "Does not exists"
        sys.exit(1)

else:
    print "Usage:" +  sys.argv[0] + " logPath"
    sys.exit(1)

logFo = open(logPath)
match = 0


for line in logPath:
    line = re.sub(r"\n","",line)
    if match == 0:
        lineMatch = re.match(r"\s+[0-9]]+\s+.*",line,flags=re.I)
        if lineMatch:
            lineTmp = lineMatch.group(0)
            match += 1
            continue

    elif match == 1:
        lineMatch = re.match(r"\s+[0-9]+\s+.*", line, flags=re.I)
        if lineMatch:
            lineMatchQuery = re.match(r".*Query\s+(.*)", lineTmp, flags=re.I)
            if lineMatchQuery:
                lineTmp = lineMatchQuery.group(1)
                lineTmp = re.sub(r"\s+", " ", lineTmp)
                lineTmp = re.sub(r"values\s*\(.*?\)", "values (x)", lineTmp, flags=re.I)
                lineTmp = re.sub(r"(=|>|<|>=|<=)\s*('|\").*?\2", "\\1 'x'", lineTmp)
                lineTmp = re.sub(r"(=|>|<|>=|<=)\s*[0-9]+", "\\1 x", lineTmp)
                lineTmp = re.sub(r"like\s+('|\").*?\1", "like 'x'", lineTmp, flags=re.I)
                lineTmp = re.sub(r"in\s+\(.*?\)", "in (x)", lineTmp, flags=re.I)
                lineTmp = re.sub(r"limit.*", "limit", lineTmp, flags=re.I)

                print lineTmp

            match = 1
            lineTmp = lineMatch.group(0)
    else:
        lineTmp += line
        match  = 1

logFo.close()