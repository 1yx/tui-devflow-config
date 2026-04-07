function cld --argument provider
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
            set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL kimi-for-coding
            set -gx ANTHROPIC_DEFAULT_SONNET_MODEL kimi-for-coding
            set -gx ANTHROPIC_DEFAULT_OPUS_MODEL kimi-for-coding
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
        case '*' ''
            echo "Usage: cld <proxy|glm|kimi|qwen|minimax> [claude args...]"
            return 1
    end
    set -e argv[1]
    claude $argv
end
