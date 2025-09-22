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
        var arch_name = system.getenv("PROCESSOR_ARCHITECTURE")
        if env.arch_map.exist(arch_name)
            return env.arch_map[arch_name]
        else
            throw runtime.exception("Unrecognizable platform name: " + arch_name)
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

var ifs = iostream.ifstream(context.cmd_args[1])
var ofs = iostream.ofstream("Product.wxs")
var reg1 = regex.build("^(.*)PRODUCT_NAME(.*)PRODUCT_VERSION(.*)$")
var reg2 = regex.build("^(.*)PRODUCT_ARCH(.*)$")

while ifs.good()
    var str = ifs.getline()
    var result = reg1.match(str)
    if !result.empty()
        ofs.println(result.str(1) + "Covariant Script Runtime - " + env.covscript_ver() + " (" + env.arch() + ")" + result.str(2) + env.covscript_ver() + result.str(3))
        continue
    end
    result = reg2.match(str)
    if !result.empty()
        ofs.println(result.str(1) + env.arch() + result.str(2))
        continue
    end
    ofs.println(str)
end