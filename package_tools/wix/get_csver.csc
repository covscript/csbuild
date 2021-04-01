import process
import regex

namespace env
    function covscript_ver()
        var abi_reg = regex.build("Version: ([0-9]+\\.[0-9]+\\.[0-9]+).*Build ([0-9]+)")
        var p = process.exec("../../build/bin/cs", {"-v"})
        var r = null, line = null
        loop; until !(r = abi_reg.search(line = p.out().getline())).empty()
        return r.str(1) + "." + r.str(2)
    end
end

system.out.print(env.covscript_ver())