module Epanet
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
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENopen(inp_file::String, rpt_file::String = "", out_file::String = "")
    """Opens an EPANET input file & reads in network data."""
    sym = Libdl.dlsym(lib, :ENopen)
    error = ccall(sym, Cint, (Cstring, Cstring, Cstring), inp_file, rpt_file, out_file)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsaveinpfile(file::String)
    """Saves a project's data to an EPANET-formatted text file (.inp)."""
    sym = Libdl.dlsym(lib, :ENsaveinpfile)
    error = ccall(sym, Cint, (Cstring,), file)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENclose()
    """Closes a project and frees all of its memory."""
    sym = Libdl.dlsym(lib, :ENclose)
    error = ccall(sym, Cint, ())
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsolveH()
    """Runs a complete hydraulic simulation with results for all time periods written
    to a temporary hydraulics file. This command is highly inneficient when multiple
    hidraulic analyses are made in the same network"""
    sym = Libdl.dlsym(lib, :ENsolveH)
    error = ccall(sym, Cint, ())
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsaveH()
    """Transfers a project's hydraulics results from its temporary hydraulics file to its 
    binary output file, where results are only reported at uniform reporting intervals."""
    sym = Libdl.dlsym(lib, :ENsaveH)
    error = ccall(sym, Cint, ())
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENopenH()
    """Opens a project's hydraulic solver."""
    sym = Libdl.dlsym(lib, :ENopenH)
    error = ccall(sym, Cint, ())
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENinitH(initialization_flag::Int = 0)
    """This function initializes storage tank levels, link status and settings, and the simulation
    time clock prior to running a hydraulic analysis.
    The initialization flag is a two digit number where the 1st (left) digit indicates if link flows
    should be re-initialized (1) or not (0), and the 2nd digit indicates if hydraulic results should
    be saved to a temporary binary hydraulics file (1) or not (0)."""
    sym = Libdl.dlsym(lib, :ENinitH)
    error = ccall(sym, Cint, (Cint,), initialization_flag)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENrunH()
    """Computes a hydraulic solution for the current point in time.
    EN_initH must have been called prior to running the EN_runH - EN_nextH loop.
    """
    current_time::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENrunH)
    error = ccall(sym, Cint, (Ref{Int32},), current_time)
    return error ≠ 0 ? _throwEpanetException(error) : current_time[]
end

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
    return error ≠ 0 ? _throwEpanetException(error) : time_step[]
end

function ENcloseH()
    """Closes the hydraulic solver freeing all of its allocated memory."""
    sym = Libdl.dlsym(lib, :ENcloseH)
    error = ccall(sym, Cint, ())
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsavehydfile(file::String)
    """Saves a project's temporary hydraulics file to disk."""
    sym = Libdl.dlsym(lib, :ENsavehydfile)
    error = ccall(sym, Cint, (Cstring,), file)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENusehydfile(file::String)
    """Uses a previously saved binary hydraulics file to supply a project's hydraulics."""
    sym = Libdl.dlsym(lib, :ENusehydfile)
    error = ccall(sym, Cint, (Cstring,), file)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsolveQ()
    """Runs a complete water quality simulation with results at uniform reporting intervals
    written to the project's binary output file."""
    sym = Libdl.dlsym(lib, :ENsolveQ)
    error = ccall(sym, Cint, ())
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENopenQ()
    """Opens a project's water quality solver."""
    sym = Libdl.dlsym(lib, :ENopenQ)
    error = ccall(sym, Cint, ())
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENinitQ(initialization_flag::Int = 0)
    """Initializes a network prior to running a water quality analysis.
    The initialization flag is a two digit number where the 1st (left) digit indicates if link flows
    should be re-initialized (1) or not (0), and the 2nd digit indicates if hydraulic results should
    be saved to a temporary binary hydraulics file (1) or not (0)."""
    sym = Libdl.dlsym(lib, :ENinitQ)
    error = ccall(sym, Cint, (Cint,), initialization_flag)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENrunQ()
    """Makes hydraulic and water quality results at the start of the current time
    period available to a project's water quality solver..
    EN_initQ must have been called prior to running the EN_runQ - EN_nextQ loop.
    """
    current_time::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENrunQ)
    error = ccall(sym, Cint, (Ref{Int32},), current_time)
    return error ≠ 0 ? _throwEpanetException(error) : current_time[]
end

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
    return error ≠ 0 ? _throwEpanetException(error) : time_step[]
end

function ENstepQ()
    """Advances a water quality simulation by a single water quality time step."""
    time_left::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENstepQ)
    error = ccall(sym, Cint, (Ref{Int32},), time_left)
    return error ≠ 0 ? _throwEpanetException(error) : time_left[]
end

function ENcloseQ()
    """Closes the water quality solver, freeing all of its allocated memory."""
    sym = Libdl.dlsym(lib, :ENcloseQ)
    error = ccall(sym, Cint, ())
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENwriteline(file::String)
    """Writes a line of text to a project's report file."""
    sym = Libdl.dlsym(lib, :ENwriteline)
    error = ccall(sym, Cint, (Cstring,), file)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENreport()
    """Writes simulation results in a tabular format to a project's report file.
    Either a full hydraulic analysis or full hydraulic and water quality analysis
    must have been run, with results saved to file, before EN_report is called. 
    In the former case, EN_saveH must also be called first to transfer results 
    from the project's intermediate hydraulics file to its output file.
    The format of the report is controlled by commands issued with EN_setreport."""
    sym = Libdl.dlsym(lib, :ENreport)
    error = ccall(sym, Cint, ())
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENresetreport()
    """Resets a project's report options to their default values."""
    sym = Libdl.dlsym(lib, :ENresetreport)
    error = ccall(sym, Cint, ())
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsetreport(file::String)
    """Processes a reporting format command."""
    sym = Libdl.dlsym(lib, :ENsetreport)
    error = ccall(sym, Cint, (Cstring,), file)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
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
    return error ≠ 0 ? _throwEpanetException(error) : (control_type[], link_index[], setting[], node_index[], level[])
end

function ENgetcount(element::Int)
    """Retrieves the number of objects of a given type in a project."""
    count::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetcount)
    error = ccall(sym, Cint, (Cint, Ref{Int32},), element, count)
    return error ≠ 0 ? _throwEpanetException(error) : count[]
end

function ENgetoption(option::Int)
    """Retrieves the value of an analysis option."""
    value::Ref{Float32} = 0
    sym = Libdl.dlsym(lib, :ENgetoption)
    error = ccall(sym, Cint, (Cint, Ref{Float32},), option, value)
    return error ≠ 0 ? _throwEpanetException(error) : value[]
end

function ENgettimeparam(parameter::Int)
    """Retrieves the value of a time parameter."""
    value::Ref{Int64} = 0
    sym = Libdl.dlsym(lib, :ENgettimeparam)
    error = ccall(sym, Cint, (Cint, Ref{Int64},), parameter, value)
    return error ≠ 0 ? _throwEpanetException(error) : value[]
end

function ENgetflowunits()
    """Retrieves a project's flow units."""
    value::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetflowunits)
    error = ccall(sym, Cint, (Ref{Int32},), value)
    return error ≠ 0 ? _throwEpanetException(error) : value[]
end

function ENgetpatternindex(id::String)
    """Retrieves the index of a time pattern given its ID name."""
    index::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetpatternindex)
    error = ccall(sym, Cint, (Cstring, Ref{Int32},), id, index)
    return error ≠ 0 ? _throwEpanetException(error) : index[]
end

function ENgetpatternid(index::Int)
    """Retrieves the ID name of a time pattern given its index."""
    id::String = repeat("\n", 32)
    sym = Libdl.dlsym(lib, :ENgetpatternid)
    error = ccall(sym, Cint, (Cint, Cstring,), index, id)
    id = rstrip(id, ['\0', '\n'])
    return error ≠ 0 ? _throwEpanetException(error) : id
end

function ENgetpatternlen(index::Int)
    """Retrieves the number of time periods in a time pattern"""
    length::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetpatternlen)
    error = ccall(sym, Cint, (Cint, Ref{Int32},), index, length)
    return error ≠ 0 ? _throwEpanetException(error) : length[]
end

function ENgetpatternvalue(index::Int = 1, period::Int = 1)
    """Retrieves a time pattern's factor for a given time period."""
    value::Ref{Float32} = 0
    sym = Libdl.dlsym(lib, :ENgetpatternvalue)
    error = ccall(sym, Cint, (Cint, Cint, Ref{Float32},), index, period, value)
    return error ≠ 0 ? _throwEpanetException(error) : value[]
end

function ENgetqualtype()
    """Retrieves the type of water quality analysis to be run."""
    qual_type::Ref{Int32} = 0
    trace_node::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetqualtype)
    error = ccall(sym, Cint, (Ref{Int32}, Ref{Int32},), qual_type, trace_node)
    return error ≠ 0 ? _throwEpanetException(error) : (qual_type[], trace_node[])
end

function ENgeterror(error_code, max_len::Int=127)
    error_message::String = repeat("\n", 127)
    sym = Libdl.dlsym(lib, :ENgeterror)
    error = ccall(sym, Cint, (Cint, Cstring, Cint,), error_code, error_message, max_len)
    error_message = rstrip(error_message, ['\0', '\n'])
    return error ≠ 0 ? _throwEpanetException(error) : error_message
end

function ENgetnodeindex(id::String)
    """Gets the index of a node given its ID"""
    index::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetnodeindex)
    error = ccall(sym, Cint, (Cstring, Ref{Int32},), id, index)
    return error ≠ 0 ? _throwEpanetException(error) : index[]
end

function ENgetnodeid(index::Int)
    """Gets the ID name of a node given its index"""
    id::String = repeat("\n", 32)
    sym = Libdl.dlsym(lib, :ENgetnodeid)
    error = ccall(sym, Cint, (Cint, Cstring,), index, id)
    id = rstrip(id, ['\0', '\n'])
    return error ≠ 0 ? _throwEpanetException(error) : id
end

function ENgetnodetype(index::Int)
    """Retrieves a node's type given its index."""
    node_type::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetnodetype)
    error = ccall(sym, Cint, (Cint, Ref{Int32},), index, node_type)
    return error ≠ 0 ? _throwEpanetException(error) : node_type[]
end

function ENgetnodevalue(index::Int, property::Int)
    """Retrieves a property value for a node."""
    value::Ref{Float32} = 0
    sym = Libdl.dlsym(lib, :ENgetnodevalue)
    error = ccall(sym, Cint, (Cint, Cint, Ref{Float32},), index, property, value)
    return error ≠ 0 ? _throwEpanetException(error) : value[]
end

function ENgetlinkindex(id::String)
    """Gets the index of a link given its ID name."""
    index::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetlinkindex)
    error = ccall(sym, Cint, (Cstring, Ref{Int32},), id, index)
    return error ≠ 0 ? _throwEpanetException(error) : index[]
end

function ENgetlinkid(index::Int)
    """Gets the ID name of a link given its index"""
    id::String = repeat("\n", 32)
    sym = Libdl.dlsym(lib, :ENgetlinkid)
    error = ccall(sym, Cint, (Cint, Cstring,), index, id)
    id = rstrip(id, ['\0', '\n'])
    return error ≠ 0 ? _throwEpanetException(error) : id
end

function ENgetlinktype(index::Int)
    """Retrieves a link's type given its index."""
    link_type::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetlinktype)
    error = ccall(sym, Cint, (Cint, Ref{Int32},), index, link_type)
    return error ≠ 0 ? _throwEpanetException(error) : link_type[]
end

function ENgetlinknodes(index::Int)
    """Gets the indexes of a link's start- and end-nodes."""
    node_1_index::Ref{Int32} = 0
    node_2_index::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetlinknodes)
    error = ccall(sym, Cint, (Cint, Ref{Int32}, Ref{Int32},), index, node_1_index, node_2_index)
    return error ≠ 0 ? _throwEpanetException(error) : (node_1_index[], node_2_index[])
end

function ENgetlinkvalue(index::Int, property::Int)
    """Retrieves a property value for a link."""
    value::Ref{Float32} = 0
    sym = Libdl.dlsym(lib, :ENgetlinkvalue)
    error = ccall(sym, Cint, (Cint, Cint, Ref{Float32},), index, property, value)
    return error ≠ 0 ? _throwEpanetException(error) : value[]
end

function ENgetversion()
    """Retrieves the toolkit API version number."""
    version::Ref{Int32} = 0
    sym = Libdl.dlsym(lib, :ENgetversion)
    error = ccall(sym, Cint, (Ref{Int32},), version)
    return error ≠ 0 ? _throwEpanetException(error) : version[]
end

function ENsetcontrol(control_index::Int, control_type::Int, link_index::Int,
                     setting::Real, node_index::Int, level::Real)
    """Sets the properties of an existing simple control."""
    sym = Libdl.dlsym(lib, :ENsetcontrol)
    error = ccall(sym, Cint, (Cint, Cint, Cint, Cfloat, Cint, Cfloat,), 
            control_index, control_type, link_index, setting, node_index, level)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsetnodevalue(index::Int, property::Int, value::Real)
    """Sets a property value for a node."""
    sym = Libdl.dlsym(lib, :ENsetnodevalue)
    error = ccall(sym, Cint, (Cint, Cint, Cfloat,), index, property, value)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsetlinkvalue(index::Int, property::Int, value::Real)
    """Sets a property value for a link."""
    sym = Libdl.dlsym(lib, :ENsetlinkvalue)
    error = ccall(sym, Cint, (Cint, Cint, Cfloat,), index, property, value)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENaddpattern(id::String)
    """Adds a new time pattern to a project."""
    sym = Libdl.dlsym(lib, :ENaddpattern)
    error = ccall(sym, Cint, (Cstring,), id)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

# TODO: Fix this.
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


function ENsetpatternvalue(index::Int, period::Int, value::Real)
    """Sets a time pattern's factor for a given time period."""
        sym = Libdl.dlsym(lib, :ENsetpatternvalue)
        error = ccall(sym, Cint, (Cint, Cint, Cfloat), index, period, value)
        return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsettimeparam(parameter::Int, value::Int)
    """Sets the value of a time parameter."""
    sym = Libdl.dlsym(lib, :ENsettimeparam)
    error = ccall(sym, Cint, (Cint, Clong), parameter, value)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsetoption(option::Int, value::Real)
    """Sets the value for an analysis option."""
    sym = Libdl.dlsym(lib, :ENsetoption)
    error = ccall(sym, Cint, (Cint, Cfloat), option, value)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

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
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

function ENsetqualtype(qual_type::Int, chem_name::String = "",
                         chem_units::String = "", trace_node::String = "")
    """Sets the type of water quality analysis to run."""
    sym = Libdl.dlsym(lib, :ENsetqualtype)
    error = ccall(sym, Cint, (Cint, Cstring, Cstring, Cstring,),
                 qual_type, chem_name, chem_units, trace_node)
    return error ≠ 0 ? _throwEpanetException(error) : nothing
end

""" Functions and commands not present in Epanet"""

struct EpanetException <: Exception 
    message::String
    EpanetException(message::String) = new(message)
end

_throwEpanetException(error) = throw(EpanetException(ENgeterror(error)))

function getDictOfNodeIndexes()
    # Open for suggestions for a more elegant solution.
    """Generates a dictionary of all nodes indexes"""
    nodes = Dict(NODE_TYPE.JUNCTION => Vector{Int}(),
                NODE_TYPE.RESERVOIR => Vector{Int}(),
                NODE_TYPE.TANK => Vector{Int}())
    index = 0
    while _lengthOfArraysOfDict(nodes) < ENgetcount(COUNT.NODE)
        try
            push!(nodes[ENgetnodetype(index)], index)
        catch EpanetException
        end
        index += 1
    end
    return nodes
end

function getDictOfLinkIndexes()
    links = Dict(LINK_TYPE.CVPIPE => Vector{Int}(),
                LINK_TYPE.PIPE => Vector{Int}(),
                LINK_TYPE.PUMP => Vector{Int}(),
                LINK_TYPE.PRV => Vector{Int}(),
                LINK_TYPE.PSV => Vector{Int}(),
                LINK_TYPE.PBV => Vector{Int}(),
                LINK_TYPE.FCV => Vector{Int}(),
                LINK_TYPE.TCV => Vector{Int}(),
                LINK_TYPE.GPV => Vector{Int}())
    index = 0
    while _lengthOfArraysOfDict(links) < ENgetcount(COUNT.LINK)
        try
            push!(links[ENgetlinktype(index)], index)
        catch EpanetException
        end
        index += 1
    end
    return links
end

_lengthOfArraysOfDict(dict::Dict) = sum([length(dict[key]) for key in keys(dict)])

""" These are codes used by the DLL functions """

struct __node_parameters
    ELEVATION::Int
    BASEDEMAND::Int
    PATTERN::Int
    EMITTER::Int
    INITQUAL::Int
    SOURCEQUAL::Int
    SOURCEPAT::Int
    SOURCETYPE::Int
    TANKLEVEL::Int
    DEMAND::Int
    HEAD::Int
    PRESSURE::Int
    QUALITY::Int
    SOURCEMASS::Int
    INITVOLUME::Int
    MIXMODEL::Int
    MIXZONEVOL::Int
    TANKDIAM::Int
    MINVOLUME::Int
    VOLCURVE::Int
    MINLEVEL::Int
    MAXLEVEL::Int
    MIXFRACTION::Int
    TANK_KBULK::Int
end
# Open for suggestions for a more elegant solution.
NODE_PARAMETER = __node_parameters(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13
                                    , 14, 15, 16, 17, 18, 19, 20, 21, 22, 23)
             
struct __link_parameters
    DIAMETER::Int
    LENGTH::Int
    ROUGHNESS::Int
    MINORLOSS::Int
    INITSTATUS::Int
    INITSETTING::Int
    KBULK::Int
    KWALL::Int
    FLOW::Int
    VELOCITY::Int
    HEADLOSS::Int
    STATUS::Int
    SETTING::Int
    ENERGY::Int
end
LINK_PARAMETER = __link_parameters(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13)
 
struct __time_parameters
    DURATION::Int
    HYDSTEP::Int
    QUALSTEP::Int
    PATTERNSTEP::Int
    PATTERNSTART::Int
    REPORTSTEP::Int
    REPORTSTART::Int
    RULESTEP::Int
    STATISTIC::Int
    PERIODS::Int
end
TIME_PARAMETER = __time_parameters(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

struct __count 
    NODE::Int
    TANK::Int
    LINK::Int
    PAT::Int
    CURVE::Int
    CONTROL::Int
end
COUNT = __count(0, 1, 2, 3, 4, 5)

struct __node_type
    JUNCTION::Int
    RESERVOIR::Int
    TANK::Int
end
NODE_TYPE = __node_type(0, 1, 2)

struct __link_type
    CVPIPE::Int
    PIPE::Int
    PUMP::Int
    PRV::Int
    PSV::Int
    PBV::Int
    FCV::Int
    TCV::Int
    GPV::Int
end
LINK_TYPE = __link_type(0, 1, 2, 3, 4, 5, 6, 7, 8)

struct __qual_analysis_types
    NONE::Int
    CHEM::Int
    AGE::Int
    TRACE::Int
end
QUAL_ANALYS_TYPE = __qual_analysis_types(0, 1, 2, 3)

struct __source_qual_types
    CONCEN::Int
    MASS::Int
    SETPOINT::Int
    FLOWPACED::Int
end
SOURCE_QUAL_TYPE = __source_qual_types(0, 1, 2, 3)

struct __flow_unit_types
    CFS::Int
    GPM::Int
    MGD::Int
    IMGD::Int
    AFD::Int
    LPS::Int
    LPM::Int
    MLD::Int
    CMH::Int
    CMD::Int
end
FLOW_UNIT_TYPE = __flow_unit_types(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)

struct __options_types
    TRIALS::Int
    ACCURACY::Int
    TOLERANCE::Int
    EMITEXPON::Int
    DEMANDMULT::Int
end
OPTIONS_TYPE = __options_types(0, 1, 2, 3, 4)

struct __control_types
    LOWLEVEL::Int
    HILEVEL::Int;
    TIMER::Int
    TIMEOFDAY::Int
end
CONTROL_TYPE = __control_types(0, 1, 2, 3)

struct __time_statistic_types
    AVERAGE::Int
    MINIMUM::Int
    MAXIMUM::Int
    RANGE::Int
end
TIME_STATISTICS_TYPE = __time_statistic_types(1, 2, 3, 4)

struct __tank_mixing_models
    MIX1::Int
    MIX2::Int
    FIFO::Int
    LIFO::Int
end
TANK_MIXING_MODEL = __tank_mixing_models(0, 1, 2, 3)

struct __report_status
    NOSAVE::Int   # Save-results-to-file flag 
    SAVE::Int
    INITFLOW::Int  # Re-initialize flow flag 
end
REPORT_STATUS = __report_status(0, 1, 10)

end #end module