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

function call_parallel(arg_list)
    var plist = new list
    foreach it in arg_list
        var b = new process.builder
        b.dir(it[0])
        b.cmd(it[1])
        b.arg(it[2])
        plist.push_back(b.start())
    end
    loop
        for it = plist.begin, it != plist.end, null
            if it.data.has_exited()
                read_to_end(it.data.out())
                it = plist.erase(it)
            else
                it.next()
            end
        end
    until plist.empty()
end

var json_reg = regex.build("^(.*)\\.json$")

function is_json_file(name)
    return !json_reg.match(name).empty()
end

if context.cmd_args.size != 2 || !is_json_file(context.cmd_args[1])
    system.out.println("csbuild: wrong command line arguments. usage: \'csbuild target.json\'")
    system.exit(0)
end

var target = utils.open_json(context.cmd_args[1])
var vlist = new array

foreach it in target.repos
    var module = it.split({'/'})[1]
    if system.path.exist("build-cache" + system.path.separator + module)
        vlist.push_back({"build-cache" + system.path.separator + module, ".\\build\\bin\\cs.exe", {"..\\..\\misc\\cmd_call.csc", "git"}})
    else
        vlist.push_back({"build-cache", "git", {"clone", target.git_repo + it, "--depth=1"}})
    end
end

system.out.println("csbuild: fetching git repository...")
call_parallel(vlist)
vlist.clear()
foreach it in target.build do vlist.push_back({"build-cache" + system.path.separator + it, ".\\build\\bin\\cs.exe", {"..\\..\\misc\\cmd_call.csc", "make"}})
system.out.println("csbuild: building packages...")
call_parallel(vlist)