#!/bin/zsh

# Arguments check
if [ 1 -ne $# ]; then
    echo "Usage: $0 [id]"
    exit 1
fi

# Add user via useradd
useradd -g users -G sudo -m -s /usr/bin/zsh $1

# Zsh shell settings
su - $1 -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sed 's/exec zsh -l//') &&\
            cp /static/zshrc ~/.zshrc"

# Install pwndbg
su - $1 -c "echo 'source /pwndbg/gdbinit.py' > ~/.gdbinit"

echo "Don't forget to set the password"
exit 0
