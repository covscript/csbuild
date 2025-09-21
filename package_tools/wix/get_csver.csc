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
    var cs_std = null
    function covscript_std()
        if env.cs_std != null
            return env.cs_std
        end
        var abi_reg = regex.build("STD Version: ([A-Z0-9]{6})")
        var p = process.exec("./build/bin/cs", {"-v"})
        var r = null, line = null
        loop; until !(r = abi_reg.search(line = p.out().getline())).empty()
        env.cs_std = r.str(1)
        return env.cs_std
    end
    @begin
    var arch_map = {
        "AMD64" : "x86_64",
        "ARM64" : "arm64",
        "x86"   : "i386"
    }.to_hash_map()
    @end
    function arch()
        if env.covscript_std() >= "250901"
            return system.arch_name
        end
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
    var cs_ver = null
    function covscript_ver()
        if env.cs_ver != null
            return env.cs_ver
        end
        var ver_reg = regex.build("Version: ([0-9]+\\.[0-9]+\\.[0-9]+).*Build ([0-9]+)")
        var p = process.exec("../../build/bin/cs", {"-v"})
        var r = null, line = null
        loop; until !(r = ver_reg.search(line = p.out().getline())).empty()
        env.cs_ver = r.str(1) + "." + r.str(2)
        return env.cs_ver
    end
end

system.out.print(env.covscript_ver() + "-" + env.arch())