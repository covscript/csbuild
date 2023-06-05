import codec.json as json
import process
import regex

namespace utils
    function open_json(path)
        var ifs = iostream.ifstream(path)
        return json.to_var(json.from_stream(ifs))
    end
end

function read_to_end(ofs)
    while !ofs.eof()
        var ch = ofs.get()
        if ofs.eof()
            break
        end
        system.out.put(ch)
    end
end

var base_path = context.cmd_args[1]
if base_path[-1] != system.path.separator
    base_path += system.path.separator
end

function build_compile(module_name, source_path, cxx_opts)
    if !system.file.exist(source_path)
        system.out.println("[" + module_name + "] Error: Target file \'" + source_path + "\' not found.")
        system.exit(0)
    end
    block
        var sys_paths = system.getenv("PATH").split({system.path.delimiter})
        var found_cxx = false
        foreach it in sys_paths
            if system.path.exist(it)
                var entries = system.path.scan(it)
                foreach entry in entries
                    if entry.type != system.path.type.dir && (entry.name == "g++" || entry.name == "g++.exe")
                        system.out.println("[" + module_name + "] CXX PATH:   " + it + system.path.separator + entry.name)
                        found_cxx = true
                        break
                    end
                end
            end
            if found_cxx
                break
            end
        end
        if !found_cxx
            system.out.println("[" + module_name + "] Error: Can't find CXX compiler")
            system.exit(0)
        end
    end
    var csdev_path = null
    try
        csdev_path = system.getenv("CS_DEV_PATH")
    catch e
        system.out.println("[" + module_name + "] Can't find environment variable of CovScript SDK \'CS_DEV_PATH\'")
        if system.is_platform_linux() && system.file.exist("/usr/lib/libcovscript.a")
            system.out.println("[" + module_name + "] Set \'CS_DEV_PATH\' to \'/usr/\' automatically in linux.")
            csdev_path = "/usr/"
        else
            system.exit(0)
        end
    end
    csdev_path = csdev_path.split({system.path.delimiter}).at(0)
    system.out.println("[" + module_name + "] CSDEV PATH: " + csdev_path)
    var file_reg = regex.build("^.*?(\\w+)\\.(c|cc|cpp|cxx)$")
    var file_name = file_reg.match(source_path)
    system.out.println("[" + module_name + "] Building module \'" + file_name.str(1) + ".cse\'...")
    system.run("g++ -std=c++14 --shared -fPIC -O3 -I\"" + csdev_path + system.path.separator + "include\" \"" + source_path + "\" -L\"" + csdev_path + system.path.separator + "lib\" -lcovscript -o " + base_path + file_name.str(1) + ".cse " + cxx_opts)
end

var path = base_path + "csbuild"
var build_script = path + system.path.separator + (system.is_platform_windows() ? "make.bat" : "make.sh")
if !system.file.exist(build_script)
    var json_reg = regex.build("^(.*)\\.json$")
    var files = system.path.scan(path)
    foreach entry in files
        if entry.type == system.path.type.reg
            if !json_reg.match(entry.name).empty()
                var info = utils.open_json(path + system.path.separator + entry.name)
                if info.Type == "Extension"
                    if info.exist("Source")
                        system.out.println("[" + info.Name + "] Source file detected, building...")
                        build_compile(info.Name, base_path + system.path.separator + info.Source, "")
                    end
                end
            end
        end
    end
else
    var b = new process.builder
    b.dir(base_path)
    if system.is_platform_windows()
        b.cmd(".\\build\\bin\\cs.exe")
        b.arg({"..\\..\\misc\\cmd_call.csc", "make"})
    else
        b.cmd("../../build/bin/cs")
        b.arg({"../../misc/cmd_call.csc", "make"})
    end
    var p = b.start()
    p.wait()
    read_to_end(p.out())
end
