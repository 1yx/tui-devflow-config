function dev --description 'TUI Dev OS entry command'
    set -l cmd $argv[1]
    set -l rest $argv[2..]

    switch "$cmd"
        case init
            dev-init $rest
        case wt
            set -l sub $rest[1]
            set -l subrest $rest[2..]
            switch "$sub"
                case new
                    dev-wt-new $subrest
                case go
                    dev-wt-go $subrest
                case finish
                    dev-wt-finish $subrest
                case ''
                    echo "Usage: dev wt <new|go|finish>"
                case '*'
                    echo "Unknown wt subcommand: $sub"
            end
        case ai
            set -l sub $rest[1]
            set -l subrest $rest[2..]
            switch "$sub"
                case loop
                    dev-ai-loop $subrest
                case commit
                    dev-ai-commit $subrest
                case review
                    dev-ai-review $subrest
                case ''
                    echo "Usage: dev ai <loop|commit|review>"
                case '*'
                    echo "Unknown ai subcommand: $sub"
            end
        case '' help
            echo "Usage: dev <command>"
            echo ""
            echo "Commands:"
            echo "  init              Initialize the project (cmux workspace + layout)"
            echo "  wt new <name>     Create a worktree + workspace"
            echo "  wt go <name>      Switch to a workspace"
            echo "  wt finish         Push, close the workspace, and remove the worktree"
            echo "  ai loop           Run the AI coding loop"
            echo "  ai commit         Generate a commit message with AI"
            echo "  ai review         Review the current branch with AI"
        case '*'
            echo "Unknown command: $cmd"
            echo "Run 'dev help' for usage."
    end
end
