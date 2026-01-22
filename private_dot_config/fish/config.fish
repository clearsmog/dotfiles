if status is-interactive
# Commands to run in interactive sessions can go here
#  fastfetch
end

fish_vi_key_bindings

fastfetch

alias python python3

alias pip pip3

function claude
    # Check if proxy is running
    if curl -s --connect-timeout 1 http://localhost:8080/health > /dev/null 2>&1
        # Proxy is up - use it
        set -gx ANTHROPIC_BASE_URL "http://localhost:8080"
        set -gx ANTHROPIC_API_KEY "test"
        echo "Using: Antigravity Proxy"
    else
        # Proxy is down - use official Claude
        set -e ANTHROPIC_BASE_URL
        set -e ANTHROPIC_API_KEY
        echo "Using: Official Claude (proxy offline)"
    end
    
    # Run the actual claude command
    command claude $argv
end
