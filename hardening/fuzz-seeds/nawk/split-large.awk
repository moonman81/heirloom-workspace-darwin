BEGIN {
    s = ""
    for (i=0; i<10000; i++) s = s " field" i
    n = split(s, a)
    print n
}
