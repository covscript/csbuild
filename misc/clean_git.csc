var base_path = system.is_platform_windows() ? ".\\build-cache" : "./build-cache"
var files = system.path.scan(base_path)
foreach entry in files
    if entry.type == system.path.type.dir && entry.name != "." && entry.name != ".."
        system.run("git -C \"" + base_path + system.path.separator + entry.name + "\" clean -dfx")
    end
end
