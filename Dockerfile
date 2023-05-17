FROM ubuntu:22.04

LABEL name binary
LABEL email tkakr7458@gmail.com

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ Asia/Seoul
ENV PYTHONIOENCODING UTF-8
	
# Copy static files
RUN mkdir -p /static
COPY zshrc /static/zshrc
COPY add_user.zsh /static/add_user.zsh
COPY start.sh /start.sh

# Set locale
COPY locale /etc/default/locale

# Replace apt server to "mirror.kakao.com"
RUN sed -i "s/[a-z\.]*\.com/mirror.kakao.com/g" /etc/apt/sources.list

# Install 32bit dependency packages
RUN dpkg --add-architecture i386 &&\
    apt-get update &&\
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386

# Install packages
RUN apt-get install -y curl gcc gdb git openssh-server sudo vim wget zsh tzdata \
                       build-essential libffi-dev libssl-dev gcc-multilib net-tools \
                       python3 python3-pip python3-dev \
                       ruby-dev

# Add User
RUN useradd -U -m binary && \
	usermod -aG sudo binary

# Zsh shell settings
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sed 's/exec zsh -l//')" &&\
    ln -s /dracula-zsh/dracula.zsh-theme ~/.oh-my-zsh/themes/dracula.zsh-theme &&\
    cp /static/zshrc ~/.zshrc

# Install python plugins
RUN pip3 install -U pip &&\
    pip3 install -U pwntools &&\
    pip3 install -U ROPgadget

# Install ruby plugins
RUN gem install one_gadget &&\
    gem install seccomp-tools

# Install pwndbg
RUN git clone https://github.com/pwndbg/pwndbg /pwndbg &&\
    cd /pwndbg &&\
    ./setup.sh

RUN apt-get update &&\
    apt-get upgrade -y &&\
    apt-get autoremove -y

WORKDIR /home/binary

EXPOSE 22
CMD [ "/start.sh" ]
