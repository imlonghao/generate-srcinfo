FROM archlinux:base-devel

RUN pacman -Syu --needed --noconfirm git

RUN useradd -m build
RUN echo "build ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
WORKDIR /home/build
USER build

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
