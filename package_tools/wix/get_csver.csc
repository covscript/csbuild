import process
import regex

namespace utils
    function filter(str, cond)
        var _s = ""
        foreach ch in str
            if cond(ch)
                _s += ch
            end
        end
        return move(_s)
    end
end

namespace env
    @begin
    var arch_map = {
        "AMD64" : "x64",
        "x86"   : "x86"
    }.to_hash_map()
    @end
    function arch()
        if system.is_platform_unix()
            var p = process.exec("arch", {})
            return p.out().getline()
        else
            var arch_name = system.getenv("PROCESSOR_ARCHITECTURE")
            if env.arch_map.exist(arch_name)
                return env.arch_map[arch_name]
            else
                throw runtime.exception("Unrecognizable platform name: " + arch_name)
            end
        end
    end
    function covscript_ver()
        var ver_reg = regex.build("Version: ([0-9]+\\.[0-9]+\\.[0-9]+).*Build ([0-9]+)")
        var p = process.exec("../../build/bin/cs", {"-v"})
        var r = null, line = null
        loop; until !(r = ver_reg.search(line = p.out().getline())).empty()
        return r.str(1) + "." + r.str(2)
    end
end

system.out.print(env.covscript_ver() + "-" + env.arch())