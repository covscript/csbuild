switch context.cmd_args[1]
case "make"
    system.run(system.is_platform_windows() ? ".\\csbuild\\make.bat" : "./csbuild/make.sh"); end
case "git"
    system.run("git fetch")
    system.run("git pull"); end
end