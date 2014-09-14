import sys; print [line.strip() for line in open(sys.argv[1])].index("fn") - [line.strip() for line in open(sys.argv[1])].index("fp") - 2 
