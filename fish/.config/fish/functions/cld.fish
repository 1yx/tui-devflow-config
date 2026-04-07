function cld --argument provider
    # If no provider or starts with '-', use CLD_DEFAULT_PROVIDER or pass through to claude
    if test -z "$provider"; or string match -q -- '-*' "$provider"
        if set -q CLD_DEFAULT_PROVIDER
            cld $CLD_DEFAULT_PROVIDER $argv
        else
            claude $argv
        end
        return
    end

    switch "$provider"
        case proxy
            set -gx ANTHROPIC_BASE_URL "https://your-proxy.example.com"
            set -gx ANTHROPIC_AUTH_TOKEN your-api-key
        case glm
            set -gx ANTHROPIC_BASE_URL "https://your-provider.example.com"
            set -gx ANTHROPIC_AUTH_TOKEN "your-api-key"
            set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "glm-5.1"
            set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "glm-5.1"
            set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "glm-5.1"
        case kimi
            set -gx ANTHROPIC_BASE_URL "https://your-provider.example.com"
            set -gx ANTHROPIC_API_KEY your-api-key
            set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "kimi-for-coding"
            set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "kimi-for-coding"
            set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "kimi-for-coding"
        case qwen
            set -gx ANTHROPIC_BASE_URL "https://your-provider.example.com"
            set -gx ANTHROPIC_AUTH_TOKEN your-api-key
            set -gx ANTHROPIC_API_KEY ""
            set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "qwen/qwen3.6-plus:free"
            set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "qwen/qwen3.6-plus:free"
            set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "qwen/qwen3.6-plus:free"
        case minimax
            set -gx ANTHROPIC_BASE_URL "https://your-provider.example.com"
            set -gx ANTHROPIC_AUTH_TOKEN your-api-key
            set -gx ANTHROPIC_API_KEY ""
            set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "minimax/minimax-m2.5:free"
            set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "minimax/minimax-m2.5:free"
            set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "minimax/minimax-m2.5:free"
        case ccswitch
            # cc-switch proxy endpoint — configure after installing cc-switch
            set -gx ANTHROPIC_BASE_URL "http://127.0.0.1:3456"
            set -gx ANTHROPIC_AUTH_TOKEN your-api-key
        case '*'
            echo "Usage: cld <proxy|glm|kimi|qwen|minimax|ccswitch> [claude args...]"
            echo "       cld [claude args...]  (uses \$CLD_DEFAULT_PROVIDER)"
            return 1
    end
    set -e argv[1]
    claude $argv
end
