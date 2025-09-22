import process
import regex

namespace env
    var cs_std = null
    function covscript_std()
        if env.cs_std != null
            return env.cs_std
        end
        var abi_reg = regex.build("STD Version: ([A-Z0-9]{6})")
        var p = process.exec("../../build/bin/cs", {"-v"})
        var r = null, line = null
        loop; until !(r = abi_reg.search(line = p.out().getline())).empty()
        env.cs_std = r.str(1)
        return env.cs_std
    end
end

if env.covscript_std() >= "250901"
    system.out.println("")
else
    system.out.println("-dCOVSCRIPT_WIX_COMPATIBLE")
end
