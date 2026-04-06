function claude-proxy
    set -gx ANTHROPIC_BASE_URL "https://your-proxy.example.com"
    set -gx ANTHROPIC_AUTH_TOKEN your-api-key
    claude $argv
end
