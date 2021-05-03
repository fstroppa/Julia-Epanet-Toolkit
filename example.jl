include("epanet_module.jl")
ENopen("C:\\Users\\ferna\\Desktop\\Net3.inp", "")
"""
epa = EpanetModule.ENopen("C:\\Users\\ferna\\Desktop\\Net3.inp", "")




epa = EpanetModule.ENopen("C:\\Users\\ferna\\Desktop\\Net3.inp", "")

epa = EpanetModule.ENopenH()
epa = EpanetModule.ENinitH()

# epa = EpanetModule.ENsolveH()


# current_time =  Ref{Int32}(5)
epa = EpanetModule.ENrunH()
# current_time[]


# time_step =  Ref{Int32}(0)
# epa = EpanetModule.ENnextH()
# time_step[]


error = EpanetModule.ENcloseH()

# epa = EpanetModule.ENsaveinpfile("test1.inp")


# err = EpanetModule.ENsolveQ()


epa = EpanetModule.ENopenQ()
epa = EpanetModule.ENinitQ()
# current_time =  Ref{Int32}(5)
epa = EpanetModule.ENrunQ()
# current_time[]

err = EpanetModule.ENstepQ()

error = EpanetModule.ENcloseQ()
# EpanetModule.ENwriteline("test.rpt")

# error = EpanetModule.ENreport()

# EpanetModule.ENresetreport()

# err = EpanetModule.ENgetcontrol(1)

# err = EpanetModule.ENgetcount(EpanetModule.EN_NODECOUNT)

# err = EpanetModule.ENgetoption(EpanetModule.EN_TOLERANCE)

err = EpanetModule.ENgettimeparam(EpanetModule.EN_DURATION)

# err = EpanetModule.ENgetflowunits()

err = EpanetModule.ENgetpatternindex("1")

err = EpanetModule.ENgetpatternid(1)

err = EpanetModule.ENgetpatternlen(1)


err = EpanetModule.ENgetpatternvalue()

err = EpanetModule.ENgetqualtype()

err = EpanetModule.ENgeterror(102, 127)

err = EpanetModule.ENgetnodeindex("129")


err = EpanetModule.ENgetnodeid(25)

err = EpanetModule.ENgetnodetype(97)

err = EpanetModule.ENgetlinkindex("129")

err = EpanetModule.ENgetlinkid(23)

err = EpanetModule.ENgetlinktype(97)

err = EpanetModule.ENgetlinknodes(27)

err = EpanetModule.ENgetlinkvalue(27, 5)

err = EpanetModule.ENgetversion()

err = EpanetModule.ENsetcontrol(5, 1, 1, 1, 1, 1)

err = EpanetModule.ENsetnodevalue(5, 1, 17.4156)
err = EpanetModule.ENgetnodevalue(5, 1)


err = EpanetModule.ENsetlinkvalue(15, 2, 7.46)
err = EpanetModule.ENgetlinkvalue(15, 2)

err = EpanetModule.ENgetpatternindex("testpattern")
err = EpanetModule.ENaddpattern("testpattern")
err = EpanetModule.ENgetpatternindex("testpattern")

err = EpanetModule.ENsetpatternvalue(1, 2, 3.5)
err = EpanetModule.ENgetpatternvalue(1, 2)

err = EpanetModule.ENsettimeparam(2, 5)
err = EpanetModule.ENgettimeparam(3)

err = EpanetModule.ENsetoption(1, .05)
err = EpanetModule.ENgetoption(1)

err = EpanetModule.ENsetstatusreport(1)
err = EpanetModule.ENsetstatusreport(4)

err = EpanetModule.ENgetqualtype()
err = EpanetModule.ENsetqualtype(2)
err = EpanetModule.ENgetqualtype()

"""