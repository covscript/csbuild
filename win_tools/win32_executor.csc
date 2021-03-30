import codec.json as json
import process
import regex

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
                link os = it.data.out()
                loop
                    var c = os.get()
                    if !os.eof()
                        system.out.put(c)
                    else
                        break
                    end
                end
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
    if system.file.is_directory("build-cache" + system.path.separator + it)
        call_parallel({{"build-cache" + system.path.separator + it, "git", {"clean", "-dfx"}}})
        vlist.push_back({"build-cache" + system.path.separator + it, "git", {"pull"}})
    else
        vlist.push_back({"build-cache", "git", {"clone", target.git_repo + it, "--depth=1"}})
    end
end

system.file.mkdir("build-cache")
system.out.println("csbuild: fetching git repository...")
call_parallel(vlist)
vlist.clear()

foreach it in target.build
    if system.is_platform_windows()
        vlist.push_back({"build-cache" + system.path.separator + it, "conhost.exe", {".\\csbuild\\make.bat"}})
    else
        vlist.push_back({"build-cache" + system.path.separator + it, "bash", {"./csbuild/make.sh"}})
    end
end

system.out.println("csbuild: building packages...")
call_parallel(vlist)