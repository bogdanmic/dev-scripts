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

The folder it creates:
 - **tools** - here downloads tools like maven, node, etc.
 - **secrets** - generates the GitHub ssh keys
 - **work** - clones all your git repositories
