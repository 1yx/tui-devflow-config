function lt --wraps='eza --tree --level 2 --icons $argv' --description 'alias lt=eza --tree --level 2 --icons $argv'
    eza --tree --level 3 --icons $argv $argv
end
