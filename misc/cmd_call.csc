switch context.cmd_args[1]
case "make"
    system.run(".\\csbuild\\make.bat"); end
case "git"
    system.run("git fetch")
    system.run("git pull")
    system.run("git clean -dfx"); end
end