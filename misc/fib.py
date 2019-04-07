def fib(n):
    if n == 0:
        return 0
    elif n == 1:
        return 1
    else:
        return fib(n-1) + fib(n-2)

def fib2(n):
    if n == 0:
        return 0
    elif n == 1:
        return 1
    else:
        v_prev = 1
        v_prev_prev = 0
        v = 0
        for i in range(2,n+1):
            v = v_prev + v_prev_prev
            v_prev_prev = v_prev
            v_prev = v
        return v

#print fib(0)
v = fib2(5000000)
print 'calc done'

