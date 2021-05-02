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
    - `vfunc=0`: pointer to a user-supplied function which accepts a pointer its argument.
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




















""" Functions not present in Epanet"""


function getEpanetErrorMessage(error)
    error ≠ 0 ? epanet_errors[error] : nothing
end


# function ENgetnodevalue(index::Int64, paramcode::Int64)
#     sym = Libdl.dlsym(lib, :ENgetnodevalue)
#     ref = Ref{Float32}(0)
#     err = ccall(sym, Cint,(Cint,Cint,Ref{Float32}), index, paramcode, ref)
#     if err != 0
#         return "Error: "*string(err)
#     end
#     return ref.x
# end


# function ENinitH(a::Int)
#     sym = Libdl.dlsym(lib, :ENinitH)
#     return ccall(sym, Cint, (Cint,), a)

# end




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

 """ These are errors produces by the DLL functions """
epanet_errors = Dict(101 => "Error 101: insufficient memory available.",
                    102 => "Error 102: no network data available.",
                    103 => "Error 103: hydraulics not initialized.",
                    104 => "Error 104: no hydraulics for water quality analysis.",
                    105 => "Error 105: water quality not initialized.",
                    106 => "Error 106: no results saved to report on.",
                    107 => "Error 107: hydraulics supplied from external file.",
                    108 => "Error 108: cannot use external file while hydraulics solver is active.",
                    109 => "Error 109: cannot change time parameter when solver is active.",
                    110 => "Error 110: cannot solve network hydraulic equations.",
                    120 => "Error 120: cannot solve water quality transport equations.",
                    200 => "Error 200: one or more errors in input file.",
                    201 => "Error 201: syntax error in following line of [%s] section ",
                    202 => "Error 202: %s %s contains illegal numeric value.",
                    203 => "Error 203: %s %s refers to undefined node.",
                    204 => "Error 204: %s %s refers to undefined link.",
                    205 => "Error 205: %s %s refers to undefined time pattern.",
                    206 => "Error 206: %s %s refers to undefined curve.",
                    207 => "Error 207: %s %s attempts to control a CV.",
                    208 => "Error 208: %s specified for undefined Node %s.",
                    209 => "Error 209: illegal %s value for Node %s.",
                    210 => "Error 210: %s specified for undefined Link %s.",
                    211 => "Error 211: illegal %s value for Link %s.",
                    212 => "Error 212: trace node %.0s %s is undefined.",
                    213 => "Error 213: illegal option value in [%s] section   ",
                    214 => "Error 214: following line of [%s] section contains too many characters",
                    215 => "Error 215: %s %s is a duplicate ID.",
                    216 => "Error 216: %s data specified for undefined Pump %s.",
                    217 => "Error 217: invalid %s data for Pump %s.",
                    219 => "Error 219: %s %s illegally connected to a tank.",
                    220 => "Error 220: %s %s illegally connected to another valve.",
                    222 => "Error 222: %s %s has same start and end nodes.",
                    223 => "Error 223: not enough nodes in network    ",
                    224 => "Error 224: no tanks or reservoirs in network.",
                    225 => "Error 225: invalid lower/upper levels for Tank %s.",
                    226 => "Error 226: no head curve supplied for Pump %s.",
                    227 => "Error 227: invalid head curve for Pump %s.",
                    230 => "Error 230: Curve %s has nonincreasing x-values.",
                    233 => "Error 233: Node %s is unconnected.",
                    240 => "Error 240: %s %s refers to undefined source.",
                    241 => "Error 241: %s %s refers to undefined control.",
                    250 => "Error 250: function call contains invalid format.",
                    251 => "Error 251: function call contains invalid parameter code.",
                    301 => "Error 301: identical file names.",
                    302 => "Error 302: cannot open input file.",
                    303 => "Error 303: cannot open report file.",
                    304 => "Error 304: cannot open binary output file.",
                    305 => "Error 305: cannot open hydraulics file.",
                    306 => "Error 306: hydraulics file does not match network data.",
                    307 => "Error 307: cannot read hydraulics file.",
                    308 => "Error 308: cannot save results to file.",
                    309 => "Error 309: cannot save results to report file.")


# epa = ENopen("C:\\Users\\ferna\\Documents\\GitHub\\ReteIdrica2\\Epanet\\Hour_3_pumps_and_Dijkstra.inp", "")
# ENopenH()
# ENinitH(0)
# ENrunH()
# t = ENgetnodevalue(2, 1)
# print(t)

