function claude-minimax
    set -gx ANTHROPIC_BASE_URL "https://your-provider.example.com"
    set -gx ANTHROPIC_AUTH_TOKEN "your-api-key"
    set -gx ANTHROPIC_API_KEY ""
    set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "minimax/minimax-m2.5:free"
    set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "minimax/minimax-m2.5:free"
    set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "minimax/minimax-m2.5:free"
    claude $argv
end
