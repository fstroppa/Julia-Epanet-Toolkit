# module EpanetModule
using Libdl

if Sys.iswindows()
    lib_path = "epanet2.dll"
elseif Sys.islinux()
    lib_path = "libepanet2.so.2"
else
    throw(ErrorException("Epanet Module is only supported for Linux and Windows (yet)"))
end

lib = Libdl.dlopen(lib_path)

function ENepanet(inp_file::String, rpt_file::String="", out_file::String="", vfunc=0)
    """Runs a complete EPANET simulation.
    ...
    # Arguments
    - `inp_file::String`: name of the input file.
    - `rpt_file::String=""`: name of an output report file.
    - `out_file::String=""`: name of an optional binary output file.
    - `vfunc=0`: pointer to a user-supplied function which accepts a pointer as its argument.
    ...
    """
    sym = Libdl.dlsym(lib, :ENepanet)
    error = ccall(sym, Cint, (Cstring, Cstring, Cstring, Cptrdiff_t), inp_file, rpt_file, out_file, vfunc)
    return getEpanetErrorMessage(error)
end

# epa = ENepanet("C:\\Users\\ferna\\Documents\\GitHub\\ReteIdrica2\\Epanet\\Hour_3_pumps_and_Dijkstra.inp", "")

function ENopen(inp_file::String, rpt_file::String = "", out_file::String = "")
    """Opens an EPANET input file & reads in network data."""
    sym = Libdl.dlsym(lib, :ENopen)
    error = ccall(sym, Cint, (Cstring, Cstring, Cstring), inp_file, rpt_file, out_file)
    return getEpanetErrorMessage(error)
end

epa = ENopen("C:\\Users\\ferna\\Desktop\\Net3.inp", "")


function ENsaveinpfile(file::String)
    """Saves a project's data to an EPANET-formatted text file (.inp)."""
    sym = Libdl.dlsym(lib, :ENsaveinpfile)
    error = ccall(sym, Cint, (Cstring,), file)
    return getEpanetErrorMessage(error)
end

# epa = ENsaveinpfile("test1.inp")

function ENclose()
    """Closes a project and frees all of its memory."""
    sym = Libdl.dlsym(lib, :ENclose)
    error = ccall(sym, Cint, ())
    return getEpanetErrorMessage(error)
end

# epa = ENclose()

function ENsolveH()
    """Runs a complete hydraulic simulation with results for all time periods written
    to a temporary hydraulics file. This command is highly inneficient when multiple
    hidraulic analyses are made in the same network"""
    sym = Libdl.dlsym(lib, :ENsolveH)
    error = ccall(sym, Cint, ())
    return getEpanetErrorMessage(error)
end

epa = ENsolveH()

function ENsaveH()
    """Transfers a project's hydraulics results from its temporary hydraulics file to its 
    binary output file, where results are only reported at uniform reporting intervals."""
    sym = Libdl.dlsym(lib, :ENsaveH)
    error = ccall(sym, Cint, ())
    return getEpanetErrorMessage(error)
end

function ENopenH()
    """Opens a project's hydraulic solver."""
    sym = Libdl.dlsym(lib, :ENopenH)
    error = ccall(sym, Cint, ())
    return getEpanetErrorMessage(error)
end

epa = ENopenH()

function ENinitH(initialization_flag::Int = 0)
    """This function initializes storage tank levels, link status and settings, and the simulation
    time clock prior to running a hydraulic analysis.
    The initialization flag is a two digit number where the 1st (left) digit indicates if link flows
    should be re-initialized (1) or not (0), and the 2nd digit indicates if hydraulic results should
    be saved to a temporary binary hydraulics file (1) or not (0)."""
    sym = Libdl.dlsym(lib, :ENinitH)
    error = ccall(sym, Cint, (Cint,), initialization_flag)
    return getEpanetErrorMessage(error)
end

epa = ENinitH()


function ENrunH()
    """Computes a hydraulic solution for the current point in time.
    EN_initH must have been called prior to running the EN_runH - EN_nextH loop.
    """
    current_time::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENrunH)
    error = ccall(sym, Cint, (Ref{Int32},), current_time)
    return error ≠ 0 ? getEpanetErrorMessage(error) : current_time[]
end

# current_time =  Ref{Int32}(5)
epa = ENrunH()
# current_time[]


function ENnextH()
    """Determines the length of time until the next hydraulic event occurs in an extended
    period simulation.
    # Examples
    ```
    ENopenH()
    ENinitH()
    simulation_end = false
    while !simulation_end
        current_time = ENrunH!()
        # Retrieve hydraulic results for time t
        time_step = ENnextH!()
        time_step == 0 ? simulation_end = true : false
    end
    ```
    """
    time_step::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENnextH)
    error = ccall(sym, Cint, (Ref{Int32},), time_step)
    return error ≠ 0 ? getEpanetErrorMessage(error) : time_step[]
end

# time_step =  Ref{Int32}(0)
# epa = ENnextH()
# time_step[]

function ENcloseH()
    """Closes the hydraulic solver freeing all of its allocated memory."""
    sym = Libdl.dlsym(lib, :ENcloseH)
    error = ccall(sym, Cint, ())
    return getEpanetErrorMessage(error)
end

error = ENcloseH()

function ENsavehydfile(file::String)
    """Saves a project's temporary hydraulics file to disk."""
    sym = Libdl.dlsym(lib, :ENsavehydfile)
    error = ccall(sym, Cint, (Cstring,), file)
    return getEpanetErrorMessage(error)
end


function ENusehydfile(file::String)
    """Uses a previously saved binary hydraulics file to supply a project's hydraulics."""
    sym = Libdl.dlsym(lib, :ENusehydfile)
    error = ccall(sym, Cint, (Cstring,), file)
    return getEpanetErrorMessage(error)
end

# epa = ENsaveinpfile("test1.inp")

function ENsolveQ()
    """Runs a complete water quality simulation with results at uniform reporting intervals
    written to the project's binary output file."""
    sym = Libdl.dlsym(lib, :ENsolveQ)
    error = ccall(sym, Cint, ())
    return getEpanetErrorMessage(error)
end

# err = ENsolveQ()

function ENopenQ()
    """Opens a project's water quality solver."""
    sym = Libdl.dlsym(lib, :ENopenQ)
    error = ccall(sym, Cint, ())
    return getEpanetErrorMessage(error)
end

epa = ENopenQ()

function ENinitQ(initialization_flag::Int = 0)
    """Initializes a network prior to running a water quality analysis.
    The initialization flag is a two digit number where the 1st (left) digit indicates if link flows
    should be re-initialized (1) or not (0), and the 2nd digit indicates if hydraulic results should
    be saved to a temporary binary hydraulics file (1) or not (0)."""
    sym = Libdl.dlsym(lib, :ENinitQ)
    error = ccall(sym, Cint, (Cint,), initialization_flag)
    return getEpanetErrorMessage(error)
end

epa = ENinitQ()


function ENrunQ()
    """Makes hydraulic and water quality results at the start of the current time
    period available to a project's water quality solver..
    EN_initQ must have been called prior to running the EN_runQ - EN_nextQ loop.
    """
    current_time::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENrunQ)
    error = ccall(sym, Cint, (Ref{Int32},), current_time)
    return error ≠ 0 ? getEpanetErrorMessage(error) : current_time[]
end

# current_time =  Ref{Int32}(5)
epa = ENrunQ()
# current_time[]

function ENnextQ()
    """Advances a water quality simulation over the time until the next hydraulic event.
    # Examples
    ```
    ENsolveH()
    ENopenQ()
    ENinitQ()
    simulation_end = false
    while !simulation_end
        current_time = ENrunQ()
        # Retrieve hydraulic results for time t
        time_step = ENnextQ()
        time_step == 0 ? simulation_end = true : false
    end
    ```
    """
    time_step::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENnextQ)
    error = ccall(sym, Cint, (Ref{Int32},), time_step)
    return error ≠ 0 ? getEpanetErrorMessage(error) : time_step[]
end

function ENstepQ()
    """Advances a water quality simulation by a single water quality time step."""
    time_left::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENstepQ)
    error = ccall(sym, Cint, (Ref{Int32},), time_left)
    return error ≠ 0 ? getEpanetErrorMessage(error) : time_left[]
end

err = ENstepQ()


function ENcloseQ()
    """Closes the water quality solver, freeing all of its allocated memory."""
    sym = Libdl.dlsym(lib, :ENcloseQ)
    error = ccall(sym, Cint, ())
    return getEpanetErrorMessage(error)
end

error = ENcloseQ()

function ENwriteline(file::String)
    """Writes a line of text to a project's report file."""
    sym = Libdl.dlsym(lib, :ENwriteline)
    error = ccall(sym, Cint, (Cstring,), file)
    return getEpanetErrorMessage(error)
end

# ENwriteline("test.rpt")

function ENreport()
    """Writes simulation results in a tabular format to a project's report file.
    Either a full hydraulic analysis or full hydraulic and water quality analysis
    must have been run, with results saved to file, before EN_report is called. 
    In the former case, EN_saveH must also be called first to transfer results 
    from the project's intermediate hydraulics file to its output file.
    The format of the report is controlled by commands issued with EN_setreport."""
    sym = Libdl.dlsym(lib, :ENreport)
    error = ccall(sym, Cint, ())
    return getEpanetErrorMessage(error)
end

# error = ENreport()

function ENresetreport()
    """Resets a project's report options to their default values."""
    sym = Libdl.dlsym(lib, :ENresetreport)
    error = ccall(sym, Cint, ())
    return getEpanetErrorMessage(error)
end

# ENresetreport()

function ENsetreport(file::String)
    """Processes a reporting format command."""
    sym = Libdl.dlsym(lib, :ENsetreport)
    error = ccall(sym, Cint, (Cstring,), file)
    return getEpanetErrorMessage(error)
end

function ENgetcontrol(control_index::Int)
    """Retrieves the parameters of a simple control statement."""
    control_type::Ref{Int32} = 0
    link_index::Ref{Int32} = 0
    setting::Ref{Float32} = 0
    node_index::Ref{Int32} = 0
    level::Ref{Float32} = 0
    sym = Libdl.dlsym(lib, :ENgetcontrol)
    error = ccall(sym, Cint, (Cint, Ref{Int32}, Ref{Int32}, Ref{Float32}, Ref{Int32}, Ref{Float32},),
                control_index, control_type, link_index, setting, node_index, level)
    return error ≠ 0 ? getEpanetErrorMessage(error) : control_index[], link_index[], setting[], node_index[], level[]
end

# err = ENgetcontrol(1)

function ENgetcount(element::Int)
    """Retrieves the number of objects of a given type in a project."""
    count::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetcount)
    error = ccall(sym, Cint, (Cint, Ref{Int32},), element, count)
    return error ≠ 0 ? getEpanetErrorMessage(error) : count[]
end

# err = ENgetcount(EN_NODECOUNT)

function ENgetoption(option::Int)
    """Retrieves the value of an analysis option."""
    value::Ref{Float32} = 0
    sym = Libdl.dlsym(lib, :ENgetoption)
    error = ccall(sym, Cint, (Cint, Ref{Float32},), option, value)
    return error ≠ 0 ? getEpanetErrorMessage(error) : value[]
end

# err = ENgetoption(EN_TOLERANCE)

function ENgettimeparam(parameter::Int)
    """Retrieves the value of a time parameter."""
    value::Ref{Int64} = 0
    sym = Libdl.dlsym(lib, :ENgettimeparam)
    error = ccall(sym, Cint, (Cint, Ref{Int64},), parameter, value)
    return error ≠ 0 ? getEpanetErrorMessage(error) : value[]
end

err = ENgettimeparam(EN_DURATION)

function ENgetflowunits()
    """Retrieves a project's flow units."""
    value::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetflowunits)
    error = ccall(sym, Cint, (Ref{Int32},), value)
    return error ≠ 0 ? getEpanetErrorMessage(error) : value[]
end

# err = ENgetflowunits()

function ENgetpatternindex(id::String)
    """Retrieves the index of a time pattern given its ID name."""
    index::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetpatternindex)
    error = ccall(sym, Cint, (Cstring, Ref{Int32},), id, index)
    return error ≠ 0 ? getEpanetErrorMessage(error) : index[]
end

err = ENgetpatternindex("1")

function ENgetpatternid(index::Int)
    """Retrieves the ID name of a time pattern given its index."""
    id::String = repeat("\n", 32)
    sym = Libdl.dlsym(lib, :ENgetpatternid)
    error = ccall(sym, Cint, (Cint, Cstring,), index, id)
    id = rstrip(id, ['\0', '\n'])
    return error ≠ 0 ? getEpanetErrorMessage(error) : id
end

err = ENgetpatternid(1)

function ENgetpatternlen(index::Int)
    """Retrieves the number of time periods in a time pattern"""
    length::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetpatternlen)
    error = ccall(sym, Cint, (Cint, Ref{Int32},), index, length)
    return error ≠ 0 ? getEpanetErrorMessage(error) : length[]
end

err = ENgetpatternlen(1)


function ENgetpatternvalue(index::Int = 1, period::Int = 1)
    """Retrieves a time pattern's factor for a given time period."""
    value::Ref{Float32} = 0
    sym = Libdl.dlsym(lib, :ENgetpatternvalue)
    error = ccall(sym, Cint, (Cint, Cint, Ref{Float32},), index, period, value)
    return error ≠ 0 ? getEpanetErrorMessage(error) : value[]
end

err = ENgetpatternvalue()

function ENgetqualtype()
    """Retrieves the type of water quality analysis to be run."""
    qual_type::Ref{Int32} = 0
    trace_node::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetqualtype)
    error = ccall(sym, Cint, (Ref{Int32}, Ref{Int32},), qual_type, trace_node)
    return error ≠ 0 ? getEpanetErrorMessage(error) : qual_type[], trace_node[]
end

err = ENgetqualtype()

function ENgeterror(error_code::Int32, max_len::Int=127)
    error_message::String = repeat("\n", 127)
    sym = Libdl.dlsym(lib, :ENgeterror)
    error = ccall(sym, Cint, (Cint, Cstring, Cint,), error_code, error_message, max_len)
    error_message = rstrip(error_message, ['\0', '\n'])
    return error ≠ 0 ? getEpanetErrorMessage(error) : error_message
end

err = ENgeterror(102, 127)


function ENgetnodeindex(id::String)
    """Gets the index of a node given its ID"""
    index::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetnodeindex)
    error = ccall(sym, Cint, (Cstring, Ref{Int32},), id, index)
    return error ≠ 0 ? getEpanetErrorMessage(error) : index[]
end

err = ENgetnodeindex("129")

function ENgetnodeid(index::Int)
    """Gets the ID name of a node given its index"""
    id::String = repeat("\n", 32)
    sym = Libdl.dlsym(lib, :ENgetnodeid)
    error = ccall(sym, Cint, (Cint, Cstring,), index, id)
    id = rstrip(id, ['\0', '\n'])
    return error ≠ 0 ? getEpanetErrorMessage(error) : id
end

err = ENgetnodeid(25)

function ENgetnodetype(index::Int)
    """Retrieves a node's type given its index."""
    node_type::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetnodetype)
    error = ccall(sym, Cint, (Cint, Ref{Int32},), index, node_type)
    return error ≠ 0 ? getEpanetErrorMessage(error) : node_type[]
end

err = ENgetnodetype(97)

function ENgetnodevalue(index::Int, property::Int)
    """Retrieves a property value for a node."""
    value::Ref{Float32} = 0
    sym = Libdl.dlsym(lib, :ENgetnodevalue)
    error = ccall(sym, Cint, (Cint, Cint, Ref{Float32},), index, property, value)
    return error ≠ 0 ? getEpanetErrorMessage(error) : value[]
end









function ENgetlinkindex(id::String)
    """Gets the index of a link given its ID name."""
    index::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetlinkindex)
    error = ccall(sym, Cint, (Cstring, Ref{Int32},), id, index)
    return error ≠ 0 ? getEpanetErrorMessage(error) : index[]
end

err = ENgetlinkindex("129")

function ENgetlinkid(index::Int)
    """Gets the ID name of a link given its index"""
    id::String = repeat("\n", 32)
    sym = Libdl.dlsym(lib, :ENgetlinkid)
    error = ccall(sym, Cint, (Cint, Cstring,), index, id)
    id = rstrip(id, ['\0', '\n'])
    return error ≠ 0 ? getEpanetErrorMessage(error) : id
end

err = ENgetlinkid(23)

function ENgetlinktype(index::Int)
    """Retrieves a link's type given its index."""
    link_type::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetlinktype)
    error = ccall(sym, Cint, (Cint, Ref{Int32},), index, link_type)
    return error ≠ 0 ? getEpanetErrorMessage(error) : link_type[]
end

err = ENgetlinktype(97)

function ENgetlinknodes(index::Int)
    """Gets the indexes of a link's start- and end-nodes."""
    node_1_index::Ref{Int32} = 0
    node_2_index::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetlinknodes)
    error = ccall(sym, Cint, (Cint, Ref{Int32}, Ref{Int32},), index, node_1_index, node_2_index)
    return error ≠ 0 ? getEpanetErrorMessage(error) : node_1_index[], node_2_index[]
end

err = ENgetlinknodes(27)

function ENgetlinkvalue(index::Int, property::Int)
    """Retrieves a property value for a link."""
    value::Ref{Float32} = 0
    sym = Libdl.dlsym(lib, :ENgetlinkvalue)
    error = ccall(sym, Cint, (Cint, Cint, Ref{Float32},), index, property, value)
    return error ≠ 0 ? getEpanetErrorMessage(error) : value[]
end

err = ENgetlinkvalue(27, 5)

function ENgetversion()
    """Retrieves the toolkit API version number."""
    version::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetversion)
    error = ccall(sym, Cint, (Ref{Int32},), version)
    return error ≠ 0 ? getEpanetErrorMessage(error) : version[]
end

err = ENgetversion()

function ENsetcontrol(control_index::Int, control_type::Int, link_index::Int,
                     setting::Int, node_index::Int, level::Int)
    """Sets the properties of an existing simple control."""
    sym = Libdl.dlsym(lib, :ENsetcontrol)
    error = ccall(sym, Cint, (Cint, Cint, Cint, Cint, Cint, Cint,), 
            control_index, control_type, link_index, setting, node_index, level)
    return getEpanetErrorMessage(error)
end

err = ENsetcontrol(5, 1, 1, 1, 1, 1)

function ENsetnodevalue(index::Int, property::Int, value::Real)
    """Sets a property value for a node."""
    sym = Libdl.dlsym(lib, :ENsetnodevalue)
    error = ccall(sym, Cint, (Cint, Cint, Cfloat,), index, property, value)
    return getEpanetErrorMessage(error)
end

err = ENsetnodevalue(5, 1, 17.4156)
err = ENgetnodevalue(5, 1)

function ENsetlinkvalue(index::Int, property::Int, value::Real)
    """Sets a property value for a link."""
    sym = Libdl.dlsym(lib, :ENsetlinkvalue)
    error = ccall(sym, Cint, (Cint, Cint, Cfloat,), index, property, value)
    return getEpanetErrorMessage(error)
end


err = ENsetlinkvalue(15, 2, 7.46)
err = ENgetlinkvalue(15, 2)

function ENaddpattern(id::String)
    """Adds a new time pattern to a project."""
    sym = Libdl.dlsym(lib, :ENaddpattern)
    error = ccall(sym, Cint, (Cstring,), id)
    return getEpanetErrorMessage(error)
end

err = ENgetpatternindex("testpattern")
err = ENaddpattern("testpattern")
err = ENgetpatternindex("testpattern")

# function ENsetpattern(index::Int, values::Array)
#     """WARNING: This function can cause compatibilities issues.
#     Use ENsetpatternvalue instead!!!
#     This function redefines (and resizes) a time pattern all at once;
#     ENsetpatternvalue revises pattern factors one at a time.
#     ...
#     # Arguments
#     - `index::Int`: a time pattern index (starting from 1).
#     - `values::Array=""`: an array of new pattern factor values.
#     ...
#     """
#     sym = Libdl.dlsym(lib, :ENsetpattern)
#     len = size(values)[1]
#     error = ccall(sym, Cint, (Cint, Array, Cint), index, values, len)
#     return getEpanetErrorMessage(error)
# end

# err = ENsetpattern(1, [1.5, 5.4, 3.0]) ## ERROR!
# err = ENgetpatternlen(1)
# err = ENgetpatternvalue(1, 2)

function ENsetpatternvalue(index::Int, period::Int, value::Real)
    """Sets a time pattern's factor for a given time period."""
        sym = Libdl.dlsym(lib, :ENsetpatternvalue)
        error = ccall(sym, Cint, (Cint, Cint, Cfloat), index, period, value)
        return getEpanetErrorMessage(error)
end

err = ENsetpatternvalue(1, 2, 3.5)
err = ENgetpatternvalue(1, 2)

function ENsettimeparam(parameter::Int, value::Int)
    """Sets the value of a time parameter."""
    sym = Libdl.dlsym(lib, :ENsettimeparam)
    error = ccall(sym, Cint, (Cint, Clong), parameter, value)
    return getEpanetErrorMessage(error)
end

err = ENsettimeparam(2, 5)
err = ENgettimeparam(3)

function ENsetoption(option::Int, value::Real)
    """Sets the value for an analysis option."""
    sym = Libdl.dlsym(lib, :ENsetoption)
    error = ccall(sym, Cint, (Cint, Cfloat), option, value)
    return getEpanetErrorMessage(error)
end

err = ENsetoption(1, .05)
err = ENgetoption(1)

function ENsetstatusreport(level_code::Int)
    """Sets the level of hydraulic status reporting.
    Status reporting writes changes in the hydraulics status of network elements to a
    project's report file as a hydraulic simulation unfolds. There are three levels of
    reporting: EN_NO_REPORT (no status reporting), EN_NORMAL_REPORT (normal reporting) 
    EN_FULL_REPORT (full status reporting).
    The full status report contains information at each trial of the solution to the 
    system hydraulic equations at each time step of a simulation. It is useful mainly
    for debugging purposes.
    If many hydraulic analyses will be run in the application it is recommended that
    status reporting be turned off (level = EN_NO_REPORT)."""
    sym = Libdl.dlsym(lib, :ENsetstatusreport)
    error = ccall(sym, Cint, (Cint,), level_code)
    return getEpanetErrorMessage(error)
end

err = ENsetstatusreport(1)
err = ENsetstatusreport(4)

function ENsetqualtype(qual_type::Int, chem_name::String = "",
                         chem_units::String = "", trace_node::String = "")
    """Sets the type of water quality analysis to run."""
    sym = Libdl.dlsym(lib, :ENsetqualtype)
    error = ccall(sym, Cint, (Cint, Cstring, Cstring, Cstring,),
                 qual_type, chem_name, chem_units, trace_node)
    return getEpanetErrorMessage(error)
end

err = ENgetqualtype()
err = ENsetqualtype(2)
err = ENgetqualtype()


""" Functions not present in Epanet"""

function getEpanetErrorMessage(error)
    error ≠ 0 ? ENgeterror(error) : nothing
end


""" These are codes used by the DLL functions """
 EN_ELEVATION  = 0;    # Node parameters 
 EN_BASEDEMAND = 1;
 EN_PATTERN    = 2;
 EN_EMITTER    = 3;
 EN_INITQUAL   = 4;
 EN_SOURCEQUAL = 5;
 EN_SOURCEPAT  = 6;
 EN_SOURCETYPE = 7;
 EN_TANKLEVEL  = 8;
 EN_DEMAND     = 9;
 EN_HEAD       = 10;
 EN_PRESSURE   = 11;
 EN_QUALITY    = 12;
 EN_SOURCEMASS = 13;
 EN_INITVOLUME = 14;
 EN_MIXMODEL   = 15;
 EN_MIXZONEVOL = 16;

 EN_TANKDIAM    = 17;
 EN_MINVOLUME   = 18;
 EN_VOLCURVE    = 19;
 EN_MINLEVEL    = 20;
 EN_MAXLEVEL    = 21;
 EN_MIXFRACTION = 22;
 EN_TANK_KBULK  = 23;

 EN_DIAMETER    = 0;    # Link parameters 
 EN_LENGTH      = 1;
 EN_ROUGHNESS   = 2;
 EN_MINORLOSS   = 3;
 EN_INITSTATUS  = 4;
 EN_INITSETTING = 5;
 EN_KBULK       = 6;
 EN_KWALL       = 7;
 EN_FLOW        = 8;
 EN_VELOCITY    = 9;
 EN_HEADLOSS    = 10;
 EN_STATUS      = 11;
 EN_SETTING     = 12;
 EN_ENERGY      = 13;

 EN_DURATION     = 0;  # Time parameters 
 EN_HYDSTEP      = 1;
 EN_QUALSTEP     = 2;
 EN_PATTERNSTEP  = 3;
 EN_PATTERNSTART = 4;
 EN_REPORTSTEP   = 5;
 EN_REPORTSTART  = 6;
 EN_RULESTEP     = 7;
 EN_STATISTIC    = 8;
 EN_PERIODS      = 9;

 EN_NODECOUNT    = 0; # Component counts 
 EN_TANKCOUNT    = 1;
 EN_LINKCOUNT    = 2;
 EN_PATCOUNT     = 3;
 EN_CURVECOUNT   = 4;
 EN_CONTROLCOUNT = 5;

 EN_JUNCTION   = 0;   # Node types 
 EN_RESERVOIR  = 1;
 EN_TANK       = 2;

 EN_CVPIPE     = 0;   # Link types 
 EN_PIPE       = 1;
 EN_PUMP       = 2;
 EN_PRV        = 3;
 EN_PSV        = 4;
 EN_PBV        = 5;
 EN_FCV        = 6;
 EN_TCV        = 7;
 EN_GPV        = 8;

 EN_NONE       = 0;   # Quality analysis types 
 EN_CHEM       = 1;
 EN_AGE        = 2;
 EN_TRACE      = 3;

 EN_CONCEN     = 0;   # Source quality types 
 EN_MASS       = 1;
 EN_SETPOINT   = 2;
 EN_FLOWPACED  = 3;

 EN_CFS        = 0;   # Flow units types 
 EN_GPM        = 1;
 EN_MGD        = 2;
 EN_IMGD       = 3;
 EN_AFD        = 4;
 EN_LPS        = 5;
 EN_LPM        = 6;
 EN_MLD        = 7;
 EN_CMH        = 8;
 EN_CMD        = 9;

 EN_TRIALS     = 0;   # Option types 
 EN_ACCURACY   = 1;
 EN_TOLERANCE  = 2;
 EN_EMITEXPON  = 3;
 EN_DEMANDMULT = 4;

 EN_LOWLEVEL   = 0;   # Control types 
 EN_HILEVEL    = 1;
 EN_TIMER      = 2;
 EN_TIMEOFDAY  = 3;

 EN_AVERAGE    = 1;   # Time statistic types 
 EN_MINIMUM    = 2; 
 EN_MAXIMUM    = 3;
 EN_RANGE      = 4;

 EN_MIX1       = 0;   # Tank mixing models 
 EN_MIX2       = 1;
 EN_FIFO       = 2;
 EN_LIFO       = 3;

 EN_NOSAVE     = 0;   # Save-results-to-file flag 
 EN_SAVE       = 1;
 EN_INITFLOW   = 10;  # Re-initialize flow flag 

