function claude-kimi
    set -gx ANTHROPIC_BASE_URL "https://your-provider.example.com"
    set -gx ANTHROPIC_API_KEY your-api-key
    set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL kimi-for-coding
    set -gx ANTHROPIC_DEFAULT_SONNET_MODEL kimi-for-coding
    set -gx ANTHROPIC_DEFAULT_OPUS_MODEL kimi-for-coding
    claude $argv
end
