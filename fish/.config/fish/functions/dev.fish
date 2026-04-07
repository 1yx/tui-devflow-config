function dev --description 'TUI Dev OS 5-step workflow'
    set -l cmd $argv[1]
    set -l rest $argv[2..]

    switch "$cmd"
        case init
            dev-init $rest
        case specify
            dev-specify $rest
        case plan
            dev-plan $rest
        case implement
            dev-implement $rest
        case archive
            dev-archive $rest
        case '' help
            echo "Usage: dev <command>"
            echo ""
            echo "5-step spec-driven workflow:"
            echo "  init              Step 1: Initialize spec tool + 3-pane layout"
            echo "  specify <name>    Step 2: Create worktree + explore + proposal"
            echo "  plan              Step 3: Generate plan + tasks + review-doc"
            echo "  implement         Step 4: Apply changes + review-code + commit"
            echo "  archive           Step 5: Archive specs + push + close worktree"
        case '*'
            echo "Unknown command: $cmd"
            echo "Run 'dev help' for usage."
    end
end
