function claude-glm
    set -gx ANTHROPIC_BASE_URL "https://your-provider.example.com"
    set -gx ANTHROPIC_AUTH_TOKEN "your-api-key"
    set -gx ANTHROPIC_DEFAULT_HAIKU_MODEL "glm-5.1"
    set -gx ANTHROPIC_DEFAULT_SONNET_MODEL "glm-5.1"
    set -gx ANTHROPIC_DEFAULT_OPUS_MODEL "glm-5.1"
    claude $argv
end
