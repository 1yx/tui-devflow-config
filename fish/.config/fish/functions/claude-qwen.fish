function claude-qwen
    set -gx ANTHROPIC_BASE_URL "https://your-provider.example.com"
    set -gx ANTHROPIC_AUTH_TOKEN "your-api-key"
    set -gx ANTHROPIC_API_KEY ""
    set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "qwen/qwen3.6-plus:free"
    set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "qwen/qwen3.6-plus:free"
    set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "qwen/qwen3.6-plus:free"
    claude $argv
end
