{import math}

{fun merge l r ->
    {list = {l.copy 0 0}}
    {while {length l} > 0 and {length r} > 0 do
        {if {get l 0} < {get r 0} then
            (list << {get l 0})
            {l.delete 0}
            else
                (list << {get r 0})
                {r.delete 0}}}
    (list <<< l <<< r)}

{fun sort list ->
    {n = {length list}}
    {return list if n < 2}
    {m = {round n / 2}}
    {l = {sort {list.left m}}}
    {r = {sort {list.right n - m}}}
    {list.clear}
    (list <<< {merge l r})}

{if __in_main__ then
    {println {sort [2.3, 1.3, 15.02, 25.02, 45, 85.14, 56.1, 35.2, 4.2, 15.4]}}}

