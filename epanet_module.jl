using Libdl
lib_path = "epanet2.dll"
lib = Libdl.dlopen(lib_path) 

function ENopen(inpFile::String, rptFile::String = "", outFile::String = "")
    sym = Libdl.dlsym(lib, :ENopen) # trocar por Enopen
    err = ccall(sym, Cint, (Cstring,Cstring,Cstring), inpFile, rptFile, outFile)
    if err != 0
        return "Error: "*string(err)
    end
end

function ENsolveH()
    sym = Libdl.dlsym(lib, :ENsolveH)
    err = ccall(sym,Cint,())
    if err != 0
        return "Error: "*string(err)
    end
end

function ENgetnodevalue(index::Int64, paramcode::Int64)
    sym = Libdl.dlsym(lib, :ENgetnodevalue)
    ref = Ref{Float32}(0)
    err = ccall(sym, Cint,(Cint,Cint,Ref{Float32}), index, paramcode, ref)
    if err != 0
        return "Error: "*string(err)
    end
    return ref.x
end

function ENopenH()
    sym = Libdl.dlsym(lib, "ENopenH")
    err = ccall(sym,Cint,())
    if err != 0
        return "Error: "*string(err)
    end
end

function ENinitH(a::Int)
    sym = Libdl.dlsym(lib, :ENinitH)
    return ccall(sym, Cint, (Cint,), a)

end

function ENrunH()
    sym = Libdl.dlsym(lib, :ENrunH)
    err = ccall(sym, Cint, (Ref{Clong},), 0)
end

epa = ENopen("C:\\Users\\ferna\\Documents\\GitHub\\ReteIdrica2\\Epanet\\Hour_3_pumps_and_Dijkstra.inp", "empty.rpt")
ENopenH()
ENinitH(0)
ENrunH()
t = ENgetnodevalue(2, 1)
print(t)
