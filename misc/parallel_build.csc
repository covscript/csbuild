import codec.json as json
import process
import regex

namespace utils
    function open_json(path)
        var ifs = iostream.ifstream(path)
        return json.to_var(json.from_stream(ifs))
    end
end

function call_parallel(max_parallel, arg_list)
    var plist = new list
    var exit_code = 0
    var failed_list = new array
    loop
        while plist.size < max_parallel && !arg_list.empty()
            var (d, c, a) = arg_list.pop_front()
            var b = new process.builder
            b.dir(d).cmd(c).arg(a).inherit_output(true)
            var p = b.start()
            if p.is_running()
                system.out.println("csbuild: process " + p.get_pid() + " started succeed.")
                plist.push_back(p)
            else
                system.out.println("csbuild: process " + p.get_pid() + " started failed.")
            end
        end
        for it = plist.begin, it != plist.end, null
            exit_code = it.data.wait_poll(10, 5)
            if exit_code != null
                var pid = it.data.get_pid()
                system.out.println("csbuild: process " + pid + " exit with code " + exit_code)
                if exit_code != 0
                    failed_list.push_back(pid)
                end
                it = plist.erase(it)
            else
                it.next()
            end
        end
    until plist.empty() && arg_list.empty()
    if failed_list.empty()
        system.out.println("csbuild: all processes finished successfully.")
    else
        system.out.println("csbuild: the following processes failed: " + failed_list.join(", "))
    end
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

var sep = system.path.separator
var cs_bin = "." + sep + "build" + sep + "bin" + sep + "cs"
if system.is_platform_windows()
    cs_bin = cs_bin + ".exe"
end
var imports_dir = "." + sep + "build" + sep + "imports"
var auto_build  = "." + sep + "misc" + sep + "auto_build.csc"
var cmd_call    = ".." + sep + ".." + sep + "misc" + sep + "cmd_call.csc"

system.out.println("csbuild: setting max concurrent jobs to " + target.max_parallel)

foreach it in target.repos
    var module = it.split({'/'})[1]
    if system.path.exist("build-cache" + sep + module)
        vlist.push_back({"build-cache" + sep + module, cs_bin, {cmd_call, "git"}})
    else
        vlist.push_back({"build-cache", "git", {"clone", target.git_repo + it, "--depth=1", "--recurse-submodules"}})
    end
end
system.out.println("csbuild: fetching git repository...")
call_parallel(target.max_parallel, vlist)

foreach it in target.build
    vlist.push_back({".", cs_bin, {"-i", imports_dir, auto_build, "build-cache" + sep + it}})
end
system.out.println("csbuild: building packages...")
call_parallel(target.max_parallel, vlist)
