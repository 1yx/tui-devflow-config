function devflow --description 'TUI Dev OS environment update manager'
    set -l cmd $argv[1]
    set -l rest $argv[2..]

    switch "$cmd"
        case update
            devflow-update $rest
        case upgrade
            devflow-upgrade $rest
        case '' help
            echo "Usage: devflow <command>"
            echo ""
            echo "Environment update commands:"
            echo "  update    Refresh indices and list outdated packages"
            echo "  upgrade   Execute all pending updates"
        case '*'
            echo "Unknown command: $cmd"
            echo "Run 'devflow help' for usage."
    end
end
