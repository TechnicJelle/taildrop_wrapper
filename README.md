# Taildrop Wrapper

A small script around the [Tailscale](https://tailscale.com/) [CLI](https://tailscale.com/kb/1080/cli)
for easier [Taildropping](https://tailscale.com/kb/1106/taildrop) on Linux

## Usage
This script is made to be as simple as possible:  
Just provide the file you want to send and the script will
open a popup where you can select the device you want to send it to.

```bash
taildrop_wrapper <file(s)>
```

## Installation
You will need the [Dart SDK](https://dart.dev/get-dart#install) to build the script.  
And make sure you have [`yad`](https://github.com/v1cont/yad) and
[`tailscale`](https://tailscale.com/download/linux) installed before running the script.

Then, just clone the repository and run `make` or `make build`. This will compile the script.  
After that, you can run `sudo make install` to actually install the script to `/usr/local/bin`.

You can even integrate it with your file manager(s) by running `make fm-integrate`.  

Currently supported file managers are:
- [Thunar](https://docs.xfce.org/xfce/thunar/start): Right click something, and select **Send To** > **Taildrop**
- _Please feel free to PR more!_

```bash
git clone https://github.com/TechnicJelle/taildrop_wrapper.git
cd taildrop_wrapper
make
sudo make install
make fm-integrate
```

## Uninstallation
To uninstall the script, just run `sudo make uninstall`.

You can also remove the file manager integration(s) by running `make fm-integration-uninstall`.
