import regex
var url_reg = regex.build("^(.*)http://mirrors\\.covariant\\.cn/cspkg_v2/index\\.json(.*)$")
var target_file = context.cmd_args[1]
var file_data = new array
var ifs = iostream.ifstream(target_file)
loop
    var line = ifs.getline()
    if !ifs.good() || ifs.eof()
        break
    end
    var match = url_reg.match(line)
    if !match.empty()
        system.out.println("Replacing CSPKG release source with nightly source...")
        file_data.push_back(match.str(1) + "http://mirrors.covariant.cn/cspkg_v2_nightly/index.json" + match.str(2))
    else
        file_data.push_back(line)
    end
end
ifs = null
var ofs = iostream.ofstream(target_file)
foreach line in file_data do ofs.println(line)
