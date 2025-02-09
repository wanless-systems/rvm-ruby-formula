# rvm dependencies according to https://docs.saltstack.com/en/latest/ref/states/all/salt.states.rvm.html
rvm-deps:
  pkg.installed:
    - pkgs:
      - bash
      - coreutils
      - gzip
      - bzip2
      - gawk
      - sed
      - curl
      - git
      - subversion




# mri dependencies according to https://docs.saltstack.com/en/latest/ref/states/all/salt.states.rvm.html
# (excluding ruby because we actually want to install custom ruby versions through rvm instead of using the system ruby)
mri-deps:
  pkg.installed:
    - pkgs:
      - curl
      - gcc
      - gcc-c++
      - make
      - patch
      - autoconf
      - automake
      - bison
      - libffi-devel
      - libtool
      - readline-devel
      - sqlite-devel
      - zlib-devel
      - openssl-devel
      - glibc-devel
      - libyaml-devel


# From: https://rvm.io/rvm/install
# We're installing in multi-user mode and this state is expecting single-user mode
rvm:
  cmd.run:
    - name: curl -sSL https://get.rvm.io | bash -s stable --quiet-curl
    - runas: {{ pillar['rvm-ruby']['user'] }}
    - unless: test -s "$HOME/.rvm/scripts/rvm"
    - require:
      - cmd: rvm-gpg
      - pkg: rvm-deps
      - pkg: mri-deps

rvm-gpg:
  cmd.run:
    - runas: {{ pillar['rvm-ruby']['user'] }}
    - name: gpg --keyserver {{ salt['pillar.get']('rvm-ruby:keyserver', 'hkp://keys.gnupg.net') }} --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB D39DC0E3
    - unless: gpg2 -k | grep 'RVM signing'

rvm-bashrc:
  cmd.run:
    - name: echo "[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm" >> $HOME/.bashrc
    - runas: {{ pillar['rvm-ruby']['user'] }}
    - unless: grep ".rvm/scripts/rvm" ~/.bashrc

{% for ruby_version in pillar['rvm-ruby']['versions'] %}
ruby-{{ ruby_version }}:
  rvm.installed:
    - user: {{ pillar['rvm-ruby']['user'] }}
    {% if pillar['rvm-ruby']['default'] is defined and pillar['rvm-ruby']['default'] == ruby_version %}
    - default: True
    {% endif %}
    # Do not attempt to install this ruby version if it is already installed...
    - unless: sudo -u {{ pillar['rvm-ruby']['user'] }} /bin/bash -c 'test -s "${HOME}/.rvm/rubies/ruby-{{ ruby_version }}"*"/bin/ruby"'
    - require:
      - cmd: rvm
{% endfor %}
