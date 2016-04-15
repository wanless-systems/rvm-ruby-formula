# RVM - Ruby - Formula

This salt formula lets you install several Ruby versions for a specific user through RVM. It will automatically install RVM for you before installing any Ruby version. This module uses the default salt RVM state (https://docs.saltstack.com/en/latest/ref/states/all/salt.states.rvm.html), but frees you from adding a lengthy custom state definition as described in the official salt documentation. It is kind of a comfortable add-on to the standard RVM salt states.

## Supported Operating Systems

This module has been tested on Debian 7/8.

If you successfully use it on a different operating system, please open a little pull request that updates this Readme. If you have problems running this module under your specific operating system, please consider contributing a fix for your operating system as a pull request.

## Usage

### Available states
`rvm-ruby`
* dynamically generates a state for each ruby version listed in the pillar under `rvm-ruby.versions`
* installs RVM dependencies and RVM itself
* adds RVM binary path to the path variable in the users .bashrc
* sets one of the installed ruby versions as the default

### Defining dependencies to available states

If you want to ensure that RVM is installed before any of your other states:
```yaml
custom-state:
  pkg.installed:
  	- name: custom-pkg
  	-require:
  	  - cmd: rvm
```

If you want to ensure that RVM is installed, bashrc is updated and a specific ruby version is available on command-line before any of your other states:
```yaml
custom-state:
  pkg.installed:
  	- name: custom-pkg
  	-require:
  	  - cmd: rvm
  	  - cmd: rvm-bashrc
  	  - rvm-ruby: ruby-[VERSION]
```

## Contributing

If you
* fixed a problem
* improved the documentation
* extended this module (e.g. adding JRuby support, more pillar examples, system-wide RVM and ruby installations, ...)
please submit your contribution as a pull request.

Thank you very much for your interest and contributions!