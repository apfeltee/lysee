{println "Input expression to evaluate or \"quit\" to leave!"}
{print "\nlysee> "}
{for input in @readln if {input.trim} do
    {print input + " ==> "}
    {break if "quit" == {input.trim}}
    {try
        {println {eval "{" + input + "}"}}
        except
            {println {__error__.message}}}
    {print "\nlysee> "}}
{println "bye-bye!"}

