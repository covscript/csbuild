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
    function arch()
        var p = process.exec("wmic", {"OS", "GET", "OSArchitecture"}); p.out().getline()
        var name = utils.filter(p.out().getline(), [](ch)->!ch.isspace())
        switch name
            default
                throw runtime.exception("Unrecognizable platform name: " + name)
            end
            case "64-bit"
                return "x64"
            end
            case "32-bit"
                return "x86"
            end
        end
    end
    function covscript_ver()
        var abi_reg = regex.build("Version: ([0-9]+\\.[0-9]+\\.[0-9]+).*Build ([0-9]+)")
        var p = process.exec("../../build/bin/cs", {"-v"})
        var r = null, line = null
        loop; until !(r = abi_reg.search(line = p.out().getline())).empty()
        return r.str(1) + "." + r.str(2)
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