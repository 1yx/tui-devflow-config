function npm
    echo (set_color red)"[Blocked]"(set_color normal) "The npm command is intercepted because this environment standardizes on pnpm."
    echo "Use pnpm instead. If you really need the original npm, run 'command npm ...'"
end
