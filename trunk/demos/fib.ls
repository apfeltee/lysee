{def fib n ->
    {if n < 2 then n else
        {fib(n - 2) + fib(n - 1)}}}

{if __in_main__ then
    {println fib 20}}
