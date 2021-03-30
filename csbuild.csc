#!/usr/bin/env cs
#
# Covariant Script Builder v2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright (C) 2017-2021 Michael Lee(李登淳)
#
# Email:   lee@covariant.cn, mikecovlee@163.com
# Github:  https://github.com/mikecovlee
# Website: http://covscript.org.cn

import codec.json as json
import process
import regex

namespace utils
    function open_json(path)
        var ifs = iostream.ifstream(path)
        return json.to_var(json.from_stream(ifs))
    end
    function save_json(val, path)
        var ofs = iostream.ofstream(path)
        ofs.print(json.to_string(json.from_var(val)))
    end
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
    function user_home()
        if system.is_platform_windows()
            return system.getenv("USERPROFILE")
        else
            return system.getenv("HOME")
        end
    end
    function covscript_home()
        try
            return system.getenv("COVSCRIPT_HOME")
        catch e; end
        if system.is_platform_windows()
            return env.user_home() + system.path.separator + "Documents" + system.path.separator + "CovScript"
        end
        if system.is_platform_linux()
            return "/usr/share/covscript"
        end
        if system.is_platform_darwin()
            return "/Applications/CovScript.app/Contents/MacOS/covscript"
        end
    end
    function platform()
        if system.is_platform_windows()
            return "windows"
        end
        if system.is_platform_linux()
            return "linux"
        end
        if system.is_platform_darwin()
            return "macos"
        end
    end
    function arch()
        if system.is_platform_unix()
            var p = process.exec("arch", {})
            return p.out().getline()
        else
            var p = process.exec("wmic", {"OS", "GET", "OSArchitecture"}); p.out().getline()
            var name = utils.filter(p.out().getline(), [](ch)->!ch.isspace())
            switch name
                default
                    throw runtime.exception("Unrecognizable platform name: " + name)
                end
                case "64-bit"
                    return "x86_64"
                end
                case "32-bit"
                    return "i386"
                end
            end
        end
    end
    function covscript_abi()
        var abi_reg = regex.build("ABI Version: ([A-Z0-9]{6})")
        var p = process.exec("./build/bin/cs", {"-v"})
        var r = null, line = null
        loop; until !(r = abi_reg.search(line = p.out().getline())).empty()
        return r.str(1)
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
if target.remote_base[-1] != '/'
    target.remote_base += '/'
end
if target.git_repo[-1] != '/'
    target.git_repo += '/'
end

system.out.println("csbuild: installing packages...")
system.file.mkdir("cspkg-repo")
system.file.mkdir("cspkg-repo" + system.path.separator + "index_files")
system.file.mkdir("cspkg-repo" + system.path.separator + "index_files" + system.path.separator + "packages")
system.file.mkdir("cspkg-repo" + system.path.separator + "index_files" + system.path.separator + "packages" + system.path.separator + "universal")
system.file.mkdir("cspkg-repo" + system.path.separator + "index_files" + system.path.separator + "packages" + system.path.separator + env.platform())
system.file.mkdir("cspkg-repo" + system.path.separator + "index_files" + system.path.separator + "packages" + system.path.separator + env.platform() + system.path.separator + env.arch())

system.file.mkdir("cspkg-repo" + system.path.separator + "universal")
system.file.mkdir("cspkg-repo" + system.path.separator + env.platform())
system.file.mkdir("cspkg-repo" + system.path.separator + env.platform() + system.path.separator + env.arch())

var idx_path = "cspkg-repo" + system.path.separator + "index_files" + system.path.separator + "packages" + system.path.separator + "universal"
var pkg_path = "cspkg-repo" + system.path.separator + "universal"
var idx_os_path = "cspkg-repo" + system.path.separator + "index_files" + system.path.separator + "packages" + system.path.separator + env.platform() + system.path.separator + env.arch()
var pkg_os_path = "cspkg-repo" + system.path.separator + env.platform() + system.path.separator + env.arch()

foreach it in target.install
    var path = "build-cache" + system.path.separator + it
    if !system.file.is_directory(path + system.path.separator + "csbuild")
        system.out.println("csbuild: configure directory not found in module \'" + it + "\'")
        continue
    end
    var files = system.path.scan(path + system.path.separator + "csbuild")
    foreach entry in files
        if entry.type == system.path.type.reg
            if is_json_file(entry.name)
                var info = utils.open_json(path + system.path.separator + "csbuild" + system.path.separator + entry.name)
                if info.Type == "Extension"
                    info.Version += "_ABI" + env.covscript_abi()
                end
                system.out.println("csbuild: building package " + info.Name + "(" + info.Version + ")...")
                var file_reg = regex.build("^.*?(\\w+\\.(cse|csp))$")
                var file_name = file_reg.match(info.Target)
                if file_name.empty() || !system.file.exists(path + system.path.separator + info.Target)
                    system.out.println("csbuild: invalid target in module \'" + it + "\'")
                    continue
                end
                if info.Type == "Extension"
                    system.file.copy(path + system.path.separator + info.Target, pkg_os_path + system.path.separator + file_name.str(1))
                    info.Target = target.remote_base + env.platform() + "/" + env.arch() + "/" + file_name.str(1)
                    info.erase("Type")
                    utils.save_json(info, idx_os_path + system.path.separator + info.Name + ".json")
                    continue
                end
                if info.Type == "Package"
                    system.file.copy(path + system.path.separator + info.Target, pkg_path + system.path.separator + file_name.str(1))
                    info.Target = target.remote_base + "universal/" + file_name.str(1)
                    info.erase("Type")
                    utils.save_json(info, idx_path + system.path.separator + info.Name + ".json")
                end
            end
        end
    end
end