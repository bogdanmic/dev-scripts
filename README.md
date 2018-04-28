config-scripts
==============

This is collection of scripts that I use on my linux machine to configure my
workspace. For now I use a **Ubuntu** distribution.

Ubuntu 18.04
------------
The [**setup.sh**](setup.sh) script when running creates directories around itself.
So it's recommended to create a folder where to clone this repository and run the script.

To  get started:
 ```bash
 $ git clone git@github.com:bogdanmic/config-scripts.git
 $ cd config-scripts
 $ ./setup.sh
 ```

 - **.bashrc** - Makes your ubuntu terminal prompt, colorful and ads the current branch name if in a git repository to the terminal prompt.
 - **bash_aliases** - Contains a sample alias command for **git status --short**
 - **SampleApplicationShortcut.desktop** - A sample file to create a shortcut for an application to be found in the Unity Search Bar. You need to place a file like this in **/usr/share/applications/**.

Apache
------
 - **http.application.domain.conf** - A sample file that shows you how to create a virtual host for a **php web application** using **HTTP** protocol, port **80**.

Php
---
 - **xdebug.ini** - This configuration for **xdebug** will allow you to turn the profiling and debugging functionality offered by xdebug, **on/off** by using a browser cookie. Those cokies can be added using marklets or browser extensions. Check out this [list of Xdebug browser extensions](http://xdebug.org/docs/remote).
