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


rvm:
  cmd:
    - run
    - name: curl -s -L get.rvm.io | bash -s stable --quiet-curl
    - user: {{ pillar['rvm-ruby']['user'] }}
    - unless: test -s "$HOME/.rvm/scripts/rvm"
    - require:
      - cmd: rvm-gpg
      - pkg: rvm-deps
      - pkg: mri-deps

rvm-gpg:
  cmd:
    - run
    - name: gpg2 --keyserver {{ salt['pillar.get']('rvm-ruby:keyserver', 'hkp://keys.gnupg.net') }} --recv-keys D39DC0E3
    - user: {{ pillar['rvm-ruby']['user'] }}
    - unless: gpg -k | grep 'RVM signing'

rvm-bashrc:
  cmd:
    - run
    - name: echo "[[ -s $HOME/.rvm/scripts/rvm ]] && source $HOME/.rvm/scripts/rvm" >> $HOME/.bashrc
    - user: {{ pillar['rvm-ruby']['user'] }}
    - unless: grep ".rvm/scripts/rvm" ~/.bashrc

{% for ruby_version in pillar['rvm-ruby']['versions'] %}
ruby-{{ ruby_version }}:
  rvm.installed:
    - user: {{ pillar['rvm-ruby']['user'] }}
    {% if pillar['rvm-ruby']['default'] is defined and pillar['rvm-ruby']['default'] == ruby_version %}
    - default: True
    {% endif %}
    - require:
      - cmd: rvm
{% endfor %}
